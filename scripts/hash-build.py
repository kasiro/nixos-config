#!/usr/bin/env python3
"""Синхронизатор хэшей для Nix-файлов.

Быстрый путь:
  * placeholder (lib.fakeHash, lib.fakeSha256, "", строка из 0/A)
      → заменяется на актуальный SRI-хэш через nix store prefetch-file;
  * валидный SRI (sha256-...) не трогается (с --verify — сверяется);
  * ${var} в owner/repo/rev/url, определённые в том же файле → резолвятся.

Медленный путь (--rebuild) для того, что не берётся из URL:
  * cargoHash, vendorHash, npmDepsHash и любые оставшиеся placeholder'ы;
  * каждый placeholder заменяется на уникальный SRI sha256-AAA…=;
  * запускается nix build --keep-going на toplevel флейка;
  * из ошибок вида `specified: X / got: Y` собираются пары X→Y;
  * X заменяется на Y в файле;
  * повтор, пока есть placeholder'ы или пока есть прогресс.

Файлы из IGNORE_FILES не читаются вообще.
Кэш URL→hash — рядом со скриптом (cache.json).

Использование:
    ./hash-sync.py [пути...] [--check] [--verify] [-v]
                   [--refresh-cache] [--no-cache]
                   [--rebuild] [--host NAME] [--flake PATH]
                   [--rebuild-max N] [--rebuild-timeout SEC]
"""

from __future__ import annotations

import argparse
import base64
import json
import re
import subprocess
import sys
import time
from collections import defaultdict
from contextlib import contextmanager
from fnmatch import fnmatch
from pathlib import Path

# --------------------------------------------------------------------------- #
#  Замеры
# --------------------------------------------------------------------------- #

TIMING: dict[str, dict] = defaultdict(lambda: {"total": 0.0, "count": 0})


@contextmanager
def timed(label: str):
    t0 = time.perf_counter()
    try:
        yield
    finally:
        dt = time.perf_counter() - t0
        TIMING[label]["total"] += dt
        TIMING[label]["count"] += 1


def print_timing_report():
    print("\n=== Тайминги (отсортировано по суммарному времени) ===")
    if not TIMING:
        print("  (нет данных)")
        return
    for label, s in sorted(TIMING.items(), key=lambda kv: -kv[1]["total"]):
        n = s["count"]
        avg = s["total"] / n if n else 0.0
        print(
            f"  {label:42s} "
            f"total={s['total'] * 1000:9.2f}ms  "
            f"n={n:5d}  "
            f"avg={avg * 1000:8.2f}ms"
        )


# --------------------------------------------------------------------------- #
#  Игнор-лист и кэш URL → hash
# --------------------------------------------------------------------------- #

CACHE_FILE = Path(__file__).resolve().parent / "cache.json"

IGNORE_FILES: list[str] = [
    # "modules/happ-nixos/*",
    # "*scratch*.nix",
]

_cache: dict[str, str] | None = None
_cache_dirty = False
_cache_hits = 0
_cache_misses = 0


def is_ignored(path: Path) -> bool:
    if not IGNORE_FILES:
        return False
    try:
        resolved = path.resolve()
    except OSError:
        return False
    candidates = {str(path), str(resolved)}
    try:
        candidates.add(str(resolved.relative_to(Path.cwd().resolve())))
    except ValueError:
        pass
    for pat in IGNORE_FILES:
        for cand in candidates:
            if fnmatch(cand, pat):
                return True
    return False


def load_cache() -> dict[str, str]:
    global _cache
    if _cache is not None:
        return _cache
    try:
        raw = json.loads(CACHE_FILE.read_text(encoding="utf-8"))
        if not isinstance(raw, dict):
            raise ValueError("ожидался объект")
        _cache = {str(k): str(v) for k, v in raw.items()}
    except FileNotFoundError:
        _cache = {}
    except (json.JSONDecodeError, ValueError, OSError) as e:
        print(f"warning: кэш {CACHE_FILE} повреждён ({e}), игнорирую", file=sys.stderr)
        _cache = {}
    return _cache


def save_cache() -> None:
    global _cache_dirty
    if not _cache_dirty or _cache is None:
        return
    try:
        tmp = CACHE_FILE.with_suffix(".json.tmp")
        tmp.write_text(json.dumps(_cache, indent=2, sort_keys=True), encoding="utf-8")
        tmp.replace(CACHE_FILE)
    except OSError as e:
        print(f"warning: не смог записать кэш {CACHE_FILE}: {e}", file=sys.stderr)
    _cache_dirty = False


def cache_key(url: str, unpack: bool) -> str:
    return f"{'nar' if unpack else 'raw'}:{url}"


def print_cache_stats() -> None:
    print("\n=== Кэш ===")
    print(f"  hits:   {_cache_hits}")
    print(f"  misses: {_cache_misses}")
    print(f"  всего:  {_cache_hits + _cache_misses}")
    print(f"  файл:   {CACHE_FILE}")


# --------------------------------------------------------------------------- #
#  Константы
# --------------------------------------------------------------------------- #

FETCHERS = (
    "fetchFromSourcehut",
    "fetchFromBitbucket",
    "fetchFromGitLab",
    "fetchFromGitHub",
    "fetchTarball",
    "fetchzip",
    "fetchurl",
)

SKIP_PREFIXES = ("/nix/store/",)

FETCHER_BLOCK_RE = re.compile(r"\b(" + "|".join(FETCHERS) + r")\b\s*\{")

SRI_RE = re.compile(r"^sha256-[A-Za-z0-9+/]{43}=?$")

_INTERP_RE = re.compile(r"\$\{([A-Za-z_][\w'-]*)\}")

# Атрибуты, для которых rebuild-loop имеет смысл:
# hash/sha256 — внутри fetch-блоков ловит быстрый путь, здесь же — везде.
# cargoHash/vendorHash/npmDepsHash/... — вычисляются только сборкой.
REBUILD_ATTRS = (
    "cargoHash",
    "vendorHash",
    "npmDepsHash",
    "pnpmDepsHash",
    "yarnDepsHash",
    "mixHash",
)


# --------------------------------------------------------------------------- #
#  Парсинг блоков
# --------------------------------------------------------------------------- #


def find_blocks(text: str):
    for m in FETCHER_BLOCK_RE.finditer(text):
        fetcher = m.group(1)
        brace_start = m.end() - 1
        depth = 0
        i = brace_start
        n = len(text)
        while i < n:
            c = text[i]
            if c == "#":
                while i < n and text[i] != "\n":
                    i += 1
                continue
            if c == '"':
                i += 1
                while i < n and text[i] != '"':
                    if text[i] == "\\":
                        i += 1
                    i += 1
            elif c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    yield (fetcher, m.start(), i + 1)
                    break
            i += 1


def get_attr_expr(block: str, name: str):
    pattern = re.compile(
        r"(?<![\w.])" + re.escape(name) + r"\s*=\s*(.*?);",
        re.DOTALL,
    )
    m = pattern.search(block)
    if not m:
        return None, None
    return m.group(1).strip(), m.span(1)


def get_hash_expr(block: str):
    for name in ("hash", "sha256"):
        expr, span = get_attr_expr(block, name)
        if span is not None:
            return expr, span
    return None, None


def unquote(s):
    if s is None:
        return None
    s = s.strip()
    m = re.fullmatch(r'"([^"]*)"', s)
    return m.group(1) if m else s


def extract_string(expr: str):
    if expr is None:
        return None
    m = re.fullmatch(r'"([^"]*)"', expr.strip())
    return m.group(1) if m else None


def try_resolve_simple_interp(expr: str, file_text: str):
    if expr is None:
        return None
    if "${" not in expr:
        return expr
    out = expr
    for _ in range(8):
        m = _INTERP_RE.search(out)
        if not m:
            break
        var = m.group(1)
        pat = re.compile(r"(?<![\w.])" + re.escape(var) + r'\s*=\s*"([^"]*)"\s*;')
        vm = pat.search(file_text)
        if not vm:
            return None
        out = out[: m.start()] + vm.group(1) + out[m.end() :]
    return None if "${" in out else out


# --------------------------------------------------------------------------- #
#  «Надо ли что-то делать?» — решается ДО сети
# --------------------------------------------------------------------------- #


def is_placeholder(expr: str) -> bool:
    expr = expr.strip()
    if expr in ("", '""', "''"):
        return True
    if re.search(r"\blib\.fake(?:Hash|Sha256)\b", expr):
        return True
    m = re.fullmatch(r'"([^"]*)"', expr)
    if m:
        v = m.group(1)
        if not v or all(c in "0A" for c in v):
            return True
    return False


def looks_like_sri(literal: str) -> bool:
    return bool(literal) and SRI_RE.match(literal) is not None


def decide(expr: str, current_literal, verify: bool) -> str:
    if current_literal is None and not is_placeholder(expr):
        return "skip-nonliteral"
    if is_placeholder(expr):
        return "compute"
    if not verify and looks_like_sri(current_literal):
        return "skip-sri"
    return "compute"


# --------------------------------------------------------------------------- #
#  Префетч (быстрый путь)
# --------------------------------------------------------------------------- #


def _nix_store_prefetch(url: str, unpack: bool) -> str:
    cmd = ["nix", "store", "prefetch-file", "--json"]
    if unpack:
        cmd.append("--unpack")
    cmd.append(url)
    try:
        out = subprocess.check_output(cmd, stderr=subprocess.PIPE)
    except FileNotFoundError:
        raise RuntimeError("nix не найден в PATH")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"nix store prefetch-file: {e.stderr.decode().strip()}")
    return json.loads(out)["hash"]


def _nix_prefetch_unpack(url: str) -> str:
    try:
        b32 = (
            subprocess.check_output(
                ["nix-prefetch-url", "--unpack", "--type", "sha256", url],
                stderr=subprocess.PIPE,
            )
            .decode()
            .strip()
        )
    except FileNotFoundError:
        raise RuntimeError("nix-prefetch-url не найден в PATH")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"nix-prefetch-url: {e.stderr.decode().strip()}")
    return (
        subprocess.check_output(
            ["nix", "hash", "to-sri", "--type", "sha256", b32],
            stderr=subprocess.PIPE,
        )
        .decode()
        .strip()
    )


def prefetch(url: str, unpack: bool) -> str:
    with timed("prefetch (subprocess, сеть!)"):
        try:
            return _nix_store_prefetch(url, unpack=unpack)
        except RuntimeError:
            if unpack:
                return _nix_prefetch_unpack(url)
            raise


def prefetch_cached(url, unpack, *, refresh_cache, no_cache) -> str:
    global _cache_dirty, _cache_hits, _cache_misses
    if no_cache:
        return prefetch(url, unpack)
    key = cache_key(url, unpack)
    cache = load_cache()
    if not refresh_cache and key in cache:
        with timed("prefetch (из кэша!)"):
            _cache_hits += 1
            return cache[key]
    _cache_misses += 1
    h = prefetch(url, unpack)
    cache[key] = h
    _cache_dirty = True
    return h


def compute_hash(fetcher, block, file_text, *, refresh_cache, no_cache):
    if fetcher in ("fetchurl", "fetchzip", "fetchTarball"):
        url, _ = get_attr_expr(block, "url")
        if not url:
            urls, _ = get_attr_expr(block, "urls")
            if urls:
                m = re.search(r'"([^"]+)"', urls)
                if m:
                    url = m.group(1)
        if not url:
            return None
        url = unquote(url)
        url = try_resolve_simple_interp(url, file_text)
        if not url or "${" in url:
            return None
        return prefetch_cached(
            url,
            unpack=(fetcher == "fetchzip"),
            refresh_cache=refresh_cache,
            no_cache=no_cache,
        )

    if fetcher in (
        "fetchFromGitHub",
        "fetchFromGitLab",
        "fetchFromBitbucket",
        "fetchFromSourcehut",
    ):
        owner = unquote(get_attr_expr(block, "owner")[0])
        repo = unquote(get_attr_expr(block, "repo")[0])
        rev = unquote(get_attr_expr(block, "rev")[0])
        owner = try_resolve_simple_interp(owner, file_text)
        repo = try_resolve_simple_interp(repo, file_text)
        rev = try_resolve_simple_interp(rev, file_text)
        if not (owner and repo and rev):
            return None
        if any("${" in x for x in (owner, repo, rev)):
            return None
        if fetcher == "fetchFromGitHub":
            url = f"https://github.com/{owner}/{repo}/archive/{rev}.tar.gz"
        elif fetcher == "fetchFromGitLab":
            url = (
                f"https://gitlab.com/{owner}/{repo}/-/archive/{rev}/{repo}-{rev}.tar.gz"
            )
        elif fetcher == "fetchFromBitbucket":
            url = f"https://bitbucket.org/{owner}/{repo}/get/{rev}.tar.gz"
        else:
            url = f"https://git.sr.ht/~{owner}/{repo}/archive/{rev}.tar.gz"
        return prefetch_cached(
            url,
            unpack=True,
            refresh_cache=refresh_cache,
            no_cache=no_cache,
        )
    return None


# --------------------------------------------------------------------------- #
#  Быстрый путь: process_file
# --------------------------------------------------------------------------- #


def process_file(path, check, verbose, verify, refresh_cache, no_cache):
    with timed("process_file (total)"):
        try:
            with timed("  read_text"):
                text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            if verbose:
                print(f"  - {path}: пропуск (не UTF-8)")
            return []

        original = text
        changes = []

        with timed("  find_blocks"):
            blocks = list(find_blocks(text))

        for fetcher, start, end in reversed(blocks):
            block = text[start:end]
            tag = f"[{path.name}] {fetcher}:"

            with timed("  get_hash_expr"):
                expr, span = get_hash_expr(block)
            if expr is None:
                continue

            current_literal = extract_string(expr)

            with timed("  decide"):
                action = decide(expr, current_literal, verify)

            if action == "skip-nonliteral":
                if verbose:
                    print(f"  - {tag} не литерал, пропуск: {expr[:60]}")
                continue
            if action == "skip-sri":
                if verbose:
                    print(f"  = {tag} уже валидный SRI, сеть не нужна")
                continue

            try:
                real = compute_hash(
                    fetcher,
                    block,
                    text,
                    refresh_cache=refresh_cache,
                    no_cache=no_cache,
                )
            except RuntimeError as e:
                print(f"  ! {path}: {fetcher}: {e}", file=sys.stderr)
                continue

            if real is None:
                if verbose:
                    print(f"  - {tag} динамический URL, оставляю для --rebuild")
                continue

            if current_literal == real:
                if verbose:
                    print(f"  = {tag} актуален (проверено сетью)")
                continue

            with timed("  replace_text"):
                new_expr = f'"{real}"'
                new_block = block[: span[0]] + new_expr + block[span[1] :]
                text = text[:start] + new_block + text[end:]

            print(f"  ✓ {path}: {fetcher}: {expr[:50]} → {new_expr}")
            changes.append((fetcher, expr, real))

        if not check and text != original:
            with timed("  write_text"):
                path.write_text(text, encoding="utf-8")

        return changes


# --------------------------------------------------------------------------- #
#  Медленный путь: --rebuild
# --------------------------------------------------------------------------- #


def placeholder_for_index(idx: int) -> str:
    """idx=0 → sha256-AAAA…=, idx=1 → sha256-…E=, idx=2 → sha256-…I=, …"""
    raw = idx.to_bytes(32, "big")
    return "sha256-" + base64.b64encode(raw).decode()


def find_all_placeholders(text: str, skip_sris: set[str] | None = None):
    """Возвращает [(attr, expr, (start, end)), ...], отсортированный по start.

    Ловит placeholder'ы в:
      * hash/sha256 внутри fetch*-блоков;
      * REBUILD_ATTRS (cargoHash, vendorHash, ...) — везде.
    Пропускает выражения вида "sha256-…=", если они в skip_sris
    (это наши собственные placeholder'ы с прошлой итерации).
    """
    skip_sris = skip_sris or set()
    results = []
    seen = set()

    # hash/sha256 внутри fetch*-блоков
    for _fetcher, b_start, b_end in find_blocks(text):
        block = text[b_start:b_end]
        for name in ("hash", "sha256"):
            expr, span = get_attr_expr(block, name)
            if span is None:
                continue
            lit = extract_string(expr)
            if lit and lit in skip_sris:
                break
            if is_placeholder(expr):
                abs_span = (b_start + span[0], b_start + span[1])
                if abs_span[0] not in seen:
                    seen.add(abs_span[0])
                    results.append((name, expr, abs_span))
            break

    # REBUILD_ATTRS где угодно
    for attr in REBUILD_ATTRS:
        pat = re.compile(
            r"(?<![\w.])" + re.escape(attr) + r"\s*=\s*(.*?);",
            re.DOTALL,
        )
        for m in pat.finditer(text):
            expr = m.group(1).strip()
            lit = extract_string(expr)
            if lit and lit in skip_sris:
                continue
            if is_placeholder(expr):
                span = m.span(1)
                if span[0] not in seen:
                    seen.add(span[0])
                    results.append((attr, expr, span))

    results.sort(key=lambda x: x[2][0])
    return results


_HASH_MISMATCH_RE = re.compile(
    r"specified:\s*(sha256-[A-Za-z0-9+/]{43}=?)"
    r"\s+got:\s*(sha256-[A-Za-z0-9+/]{43}=?)",
)


def parse_hash_mismatches(text: str) -> dict[str, str]:
    return {m.group(1): m.group(2) for m in _HASH_MISMATCH_RE.finditer(text)}


def do_rebuild_loop(
    files: list[Path],
    flake: str,
    host: str,
    max_iter: int,
    timeout: int,
    verbose: bool,
) -> bool:
    """Возвращает True, если все placeholder'ы удалось разрешить."""
    our_placeholders: set[str] = set()
    counter = 0
    attr_path = f"nixosConfigurations.{host}.config.system.build.toplevel"
    cmd_base = ["nix", "build", "--no-link", "--keep-going"]

    for iteration in range(1, max_iter + 1):
        # --- 1. Сканируем ---
        to_replace = []  # (path, text, entries)
        total = 0
        for f in files:
            try:
                text = f.read_text(encoding="utf-8")
            except (OSError, UnicodeDecodeError):
                continue
            entries = find_all_placeholders(text, skip_sris=our_placeholders)
            if entries:
                to_replace.append((f, text, entries))
                total += len(entries)

        if not to_replace:
            print(f"[rebuild] итерация {iteration}: placeholder'ов нет, готово")
            return True

        print(
            f"[rebuild] итерация {iteration}: {total} placeholder(ов) в {len(to_replace)} файлах"
        )

        # --- 2. Заменяем на уникальные SRI ---
        ph_to_file: dict[str, Path] = {}
        for f, text, entries in to_replace:
            entries_sorted = sorted(entries, key=lambda x: x[2][0])
            assigns = []
            for attr, expr, span in entries_sorted:
                ph = placeholder_for_index(counter)
                counter += 1
                our_placeholders.add(ph)
                ph_to_file[ph] = f
                assigns.append((ph, attr, expr, span))
            new_text = text
            for ph, attr, expr, span in reversed(assigns):
                new_text = new_text[: span[0]] + f'"{ph}"' + new_text[span[1] :]
                if verbose:
                    print(f"    {f}: {attr}: {expr[:40]} → {ph}")
            f.write_text(new_text, encoding="utf-8")

        # --- 3. Собираем ---
        cmd = cmd_base + [f"{flake}#{attr_path}"]
        print(f"[rebuild] {' '.join(cmd)} (timeout={timeout}s)")
        with timed("rebuild (nix build)"):
            try:
                proc = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    timeout=timeout,
                )
            except subprocess.TimeoutExpired:
                print(f"  ! timeout после {timeout}s", file=sys.stderr)
                return False
            except FileNotFoundError:
                print("  ! nix не найден в PATH", file=sys.stderr)
                return False
        print(f"[rebuild] exit={proc.returncode}")

        if proc.returncode == 0:
            print(
                "[rebuild] сборка успешна, но placeholder'ы остались — "
                "они в неиспользуемых путях. Выход."
            )
            return False

        # --- 4. Парсим ошибки ---
        combined = (proc.stderr or "") + "\n" + (proc.stdout or "")
        if verbose:
            tail = combined.strip().splitlines()[-25:]
            print("[rebuild] хвост вывода:")
            for line in tail:
                print(f"    | {line}")

        mismatches = parse_hash_mismatches(combined)
        if not mismatches:
            print(
                "[rebuild] сборка упала, но hash mismatch не найден — "
                "не могу продолжать",
                file=sys.stderr,
            )
            return False

        print(f"[rebuild] несовпадений: {len(mismatches)}")

        # --- 5. Применяем замены ---
        replaced = 0
        for ph, real in mismatches.items():
            f = ph_to_file.get(ph)
            if f is None:
                if verbose:
                    print(f"    ? неизвестный placeholder {ph[:20]}…, пропуск")
                continue
            text = f.read_text(encoding="utf-8")
            old = f'"{ph}"'
            if old not in text:
                continue
            f.write_text(text.replace(old, f'"{real}"'), encoding="utf-8")
            our_placeholders.discard(ph)
            print(f"    ✓ {f}: {ph} → {real}")
            replaced += 1

        if replaced == 0:
            print("[rebuild] ни одной замены — прогресса нет, выхожу")
            return False

    print(f"[rebuild] превышено {max_iter} итераций", file=sys.stderr)
    return False


# --------------------------------------------------------------------------- #
#  Сбор файлов
# --------------------------------------------------------------------------- #


def collect_files(paths):
    with timed("collect_files (total)"):
        files = []
        for p in paths:
            path = Path(p)
            if path.is_file():
                if path.suffix == ".nix" and not str(path).startswith(SKIP_PREFIXES):
                    files.append(path)
            elif path.is_dir():
                for f in path.rglob("*.nix"):
                    if not str(f).startswith(SKIP_PREFIXES):
                        files.append(f)

        seen = set()
        out = []
        skipped = 0
        for f in files:
            rp = f.resolve()
            if rp in seen:
                continue
            seen.add(rp)
            if is_ignored(f):
                skipped += 1
                continue
            out.append(f)

        if skipped:
            print(f"[collect_files] пропущено по IGNORE_FILES: {skipped}")
        return out


# --------------------------------------------------------------------------- #
#  main
# --------------------------------------------------------------------------- #


def main():
    ap = argparse.ArgumentParser(
        description="Синхронизирует хэши в fetch-вызовах Nix-файлов.",
    )
    ap.add_argument(
        "paths", nargs="*", default=["."], help="файлы/директории (по умолчанию — .)"
    )
    ap.add_argument("--check", action="store_true", help="только проверить, не менять")
    ap.add_argument(
        "--verify",
        action="store_true",
        help="сверять даже SRI (медленно, лезет в сеть)",
    )
    ap.add_argument(
        "--refresh-cache", action="store_true", help="игнорировать кэш, пересчитать"
    )
    ap.add_argument("--no-cache", action="store_true", help="не читать и не писать кэш")
    ap.add_argument(
        "--rebuild", action="store_true", help="включить медленный путь через nix build"
    )
    ap.add_argument(
        "--host", default="nixos", help="имя хоста в flake (по умолчанию nixos)"
    )
    ap.add_argument("--flake", default=".", help="путь к flake (по умолчанию .)")
    ap.add_argument(
        "--rebuild-max",
        type=int,
        default=10,
        help="максимум итераций nix build (по умолчанию 10)",
    )
    ap.add_argument(
        "--rebuild-timeout",
        type=int,
        default=3600,
        help="таймаут одной сборки в секундах (по умолчанию 3600)",
    )
    ap.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args()

    if args.check and args.rebuild:
        print(
            "warning: --check + --rebuild несовместимы, отключаю --rebuild",
            file=sys.stderr,
        )
        args.rebuild = False

    t_start = time.perf_counter()

    with timed("collect_files (caller)"):
        files = collect_files(args.paths)
    if not files:
        print("Нет .nix файлов для сканирования.", file=sys.stderr)
        return 1

    # --- Быстрый путь ---
    total = 0
    with timed("process_all_files"):
        for f in files:
            try:
                total += len(
                    process_file(
                        f,
                        check=args.check,
                        verbose=args.verbose,
                        verify=args.verify,
                        refresh_cache=args.refresh_cache,
                        no_cache=args.no_cache,
                    )
                )
            except Exception as e:
                print(f"error: {f}: {e}", file=sys.stderr)

    if not args.no_cache:
        save_cache()

    # --- Медленный путь ---
    rebuild_ok = None
    if args.rebuild:
        rebuild_ok = do_rebuild_loop(
            files=files,
            flake=args.flake,
            host=args.host,
            max_iter=args.rebuild_max,
            timeout=args.rebuild_timeout,
            verbose=args.verbose,
        )

    elapsed = time.perf_counter() - t_start

    print_timing_report()
    if not args.no_cache:
        print_cache_stats()
    print(f"\nОбщее время запуска: {elapsed:.3f}s")

    if args.check and total:
        print(f"\n{total} устаревших хэшей. Запустите без --check, чтобы исправить.")
        return 2

    if total:
        print(f"\nОбновлено хэшей: {total}.")
    elif args.verbose and not args.rebuild:
        print("Все хэши актуальны.")

    if args.rebuild and rebuild_ok is False:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
