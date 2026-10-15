#!/usr/bin/env python3
"""Синхронизатор хэшей для Nix-файлов.

Правила замены:
  * placeholder (lib.fakeHash, lib.fakeSha256, "", строка из 0/A)
      → заменяется на актуальный SRI-хэш;
  * строковый литерал в форме SRI (sha256-...)
      → по умолчанию НЕ проверяется (быстро). С --verify — сверяется;
  * невалидный строковый литерал (старый base32 и т.п.)
      → пересчитывается;
  * динамические ${var} в owner/repo/rev/url, определённые в том же файле
      → разрешаются через поиск `var = "…";` и участвуют в префетче;
  * cargoHash = lib.fakeHash в buildRustPackage-блоке
      → вычисляется через nix-build (медленно, минуты). Отключается --no-cargo;
  * любое другое выражение (например, `hash = hashes.lantern;`)
      → не трогается.

Файлы из IGNORE_FILES не читаются и не обрабатываются вообще.

Кэш URL→hash лежит рядом со скриптом (cache.json).
Кэшируются и fetch-хэши (по URL), и cargoHash (по нормализованному
тексту блока сборки). Сбрасывается флагами --refresh-cache / --no-cache.

Использование:
    ./hash-sync.py [пути...] [--check] [--verify] [-v]
                   [--refresh-cache] [--no-cache] [--no-cargo]
"""

from __future__ import annotations

import argparse
import hashlib
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
#  Инфраструктура замеров
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
        total = s["total"]
        n = s["count"]
        avg = total / n if n else 0.0
        print(
            f"  {label:42s} "
            f"total={total * 1000:9.2f}ms  "
            f"n={n:5d}  "
            f"avg={avg * 1000:8.2f}ms"
        )


# --------------------------------------------------------------------------- #
#  Игнор-лист и кэш
# --------------------------------------------------------------------------- #

CACHE_FILE = Path(__file__).resolve().parent / "cache.json"

# Файлы/паттерны, которые НЕ трогаем вообще. fnmatch-семантика.
IGNORE_FILES: list[str] = [
    # "home/kasiro_programs/zed_editor.nix",
    "modules/happ-nixos/*",
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
        print(
            f"warning: кэш {CACHE_FILE} повреждён ({e}), игнорирую",
            file=sys.stderr,
        )
        _cache = {}
    return _cache


def save_cache() -> None:
    global _cache_dirty
    if not _cache_dirty or _cache is None:
        return
    try:
        tmp = CACHE_FILE.with_suffix(".json.tmp")
        tmp.write_text(
            json.dumps(_cache, indent=2, sort_keys=True),
            encoding="utf-8",
        )
        tmp.replace(CACHE_FILE)
    except OSError as e:
        print(f"warning: не смог записать кэш {CACHE_FILE}: {e}", file=sys.stderr)
    _cache_dirty = False


def cache_key(url: str, unpack: bool) -> str:
    return f"{'nar' if unpack else 'raw'}:{url}"


def print_cache_stats() -> None:
    total = _cache_hits + _cache_misses
    print("\n=== Кэш ===")
    print(f"  hits:   {_cache_hits}")
    print(f"  misses: {_cache_misses}")
    print(f"  всего:  {total}")
    print(f"  файл:   {CACHE_FILE}")


# --- нормализация для ключа cargoHash ------------------------------------- #

# Все хэш-поля, значения которых должны быть вырезаны перед хэшированием
# блока сборки в ключ кэша. Иначе правка src.hash инвалидирует cargo-кэш.
_HASH_VALUE_RE = re.compile(r'"sha256-[A-Za-z0-9+/]+=?"')
_FAKE_HASH_RE = re.compile(r"\blib\.fake(?:Hash|Sha256)\b")


def normalize_for_cache_key(text: str) -> str:
    """Заменяет конкретные хэш-значения на маркер _HASH_, чтобы ключ
    зависел только от структуры блока (rev, owner, version, Cargo.lock и т.д.)."""
    out = _HASH_VALUE_RE.sub('"_HASH_"', text)
    out = _FAKE_HASH_RE.sub('"_HASH_"', out)
    return out


def cargo_cache_key(assignment_text: str) -> str:
    normalized = normalize_for_cache_key(assignment_text)
    digest = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
    return f"cargo:{digest}"


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

CARGO_HASH_PLACEHOLDER_RE = re.compile(
    r"cargoHash\s*=\s*(?:lib\.fakeHash|lib\.fakeSha256|\"\"|'')\s*;"
)


# --------------------------------------------------------------------------- #
#  Поиск блоков фетчеров
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
#  «Надо ли что-то делать?»
# --------------------------------------------------------------------------- #


def is_placeholder(expr: str) -> bool:
    expr = expr.strip()
    if expr in ("", '""'):
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


def prefetch_cached(
    url: str, unpack: bool, *, refresh_cache: bool, no_cache: bool
) -> str:
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
    hash_ = prefetch(url, unpack)
    cache[key] = hash_
    _cache_dirty = True
    return hash_


def compute_hash(
    fetcher: str,
    block: str,
    file_text: str,
    *,
    refresh_cache: bool,
    no_cache: bool,
):
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
            url, unpack=True, refresh_cache=refresh_cache, no_cache=no_cache
        )

    return None


# --------------------------------------------------------------------------- #
#  cargoHash — вычисляется через nix-build, НЕ через prefetch
# --------------------------------------------------------------------------- #


def find_flake_root(start: Path) -> Path | None:
    p = start.resolve()
    for _ in range(30):
        if (p / "flake.nix").exists():
            return p
        if p.parent == p:
            return None
        p = p.parent
    return None


def find_cargo_hash_assignment(text: str, cargo_pos: int):
    prefix = text[:cargo_pos]
    bp_matches = list(re.finditer(r"\bbuildRustPackage\b", prefix))
    if not bp_matches:
        return None
    bp = bp_matches[-1]

    j = bp.start() - 1
    while j >= 0 and (text[j].isalnum() or text[j] in "_'\" .\t\n"):
        j -= 1
    if j < 0 or text[j] != "=":
        return None
    eq_pos = j

    k = eq_pos - 1
    while k >= 0 and text[k] in " \t\n":
        k -= 1
    name_end = k + 1
    while k >= 0 and (text[k].isalnum() or text[k] in "_-'"):
        k -= 1
    name_start = k + 1
    if name_start == name_end:
        return None
    name = text[name_start:name_end]
    if not re.match(r"[A-Za-z_]", name):
        return None

    brace_pos = text.find("{", bp.end())
    if brace_pos < 0:
        return None

    depth = 0
    i = brace_pos
    n = len(text)
    close_pos = None
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
                close_pos = i
                break
        i += 1
    if close_pos is None:
        return None

    semi = text.find(";", close_pos)
    if semi < 0:
        return None

    return name, name_start, semi + 1


def compute_cargo_hash(
    assignment_text: str, flake_root: Path | None, timeout: int, verbose: bool
):
    """Прогоняет nix-build на assignment_text и парсит got: sha256-….

    Возвращает (hash, err_msg). hash=None если не удалось.
    """
    if flake_root is not None:
        pkgs_expr = (
            f'(builtins.getFlake "{flake_root}")'
            f".inputs.nixpkgs.legacyPackages.x86_64-linux"
        )
        impure = ["--impure"]
        tmp_dir = flake_root
    else:
        pkgs_expr = "import <nixpkgs> { }"
        impure = []
        tmp_dir = Path("/tmp")

    wrapper = f"""
let
  pkgs = {pkgs_expr};
  lib = pkgs.lib;
in
{{ {assignment_text} }}
"""
    tmp = tmp_dir / ".hash-sync-cargo-eval.nix"
    try:
        tmp.write_text(wrapper, encoding="utf-8")
    except OSError as e:
        return None, f"не смог записать {tmp}: {e}"

    if verbose:
        print(f"    [cargo] nix-build {tmp} (timeout={timeout}s)")

    try:
        proc = subprocess.run(
            ["nix-build", "--no-out-link", *impure, str(tmp)],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return None, f"timeout ({timeout}s)"
    except FileNotFoundError:
        return None, "nix-build не найден"
    finally:
        try:
            tmp.unlink()
        except OSError:
            pass

    combined = (proc.stderr or "") + "\n" + (proc.stdout or "")
    m = re.search(r"got:\s+(sha256-[A-Za-z0-9+/]+=?)", combined)
    if m:
        return m.group(1), None

    if proc.returncode == 0:
        return None, "already-ok (nix-build завершился успешно)"

    tail = combined.strip().splitlines()[-12:]
    return None, "nix-build fail:\n    " + "\n    ".join(tail)


# --------------------------------------------------------------------------- #
#  Обработка файлов
# --------------------------------------------------------------------------- #


def process_file(
    path: Path,
    check: bool,
    verbose: bool,
    verify: bool,
    refresh_cache: bool,
    no_cache: bool,
    no_cargo: bool,
    cargo_timeout: int,
):
    global _cache_dirty, _cache_hits, _cache_misses

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

        # ---------- 1. fetch* блоки: hash / sha256 ----------
        with timed("  find_blocks"):
            blocks = list(find_blocks(text))

        for fetcher, start, end in reversed(blocks):
            block = text[start:end]
            tag = f"[{path.name}] {fetcher}:"

            with timed("  get_hash_expr"):
                expr, span = get_hash_expr(block)
            if expr is None:
                if verbose:
                    print(f"  - {tag} нет атрибута hash/sha256")
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
                    print(f"  - {tag} динамический URL, пропуск")
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

        # ---------- 2. cargoHash ----------
        if not no_cargo:
            cargo_matches = list(CARGO_HASH_PLACEHOLDER_RE.finditer(text))
            for m in cargo_matches:
                found = find_cargo_hash_assignment(text, m.start())
                if not found:
                    if verbose:
                        print(f"  - [{path.name}] cargoHash: не нашёл enclosing блок")
                    continue
                name, a_start, a_end = found
                snippet = text[a_start:a_end]

                key = cargo_cache_key(snippet)
                cache = load_cache()

                # --- кэш-попадание ---
                if not no_cache and not refresh_cache and key in cache:
                    with timed("  cargo_hash (из кэша!)"):
                        h = cache[key]
                    new_snippet = CARGO_HASH_PLACEHOLDER_RE.sub(
                        f'cargoHash = "{h}";', snippet
                    )
                    text = text[:a_start] + new_snippet + text[a_end:]
                    print(f"  ✓ {path}: {name}: cargoHash → {h} (из кэша)")
                    changes.append(("cargoHash", "lib.fakeHash", h))
                    _cache_hits += 1
                    continue

                # --- кэш-промах: собираем ---
                print(
                    f"  ⏳ {path}: {name}: cargoHash placeholder — запускаю nix-build "
                    f"(может занять минуты)..."
                )
                flake_root = find_flake_root(path)
                with timed("  cargo_hash (nix-build)"):
                    h, err = compute_cargo_hash(
                        snippet, flake_root, cargo_timeout, verbose
                    )

                if h is None:
                    if err == "already-ok (nix-build завершился успешно)":
                        if verbose:
                            print(f"  = {path}: {name}: cargoHash уже актуален")
                    else:
                        print(
                            f"  ! {path}: {name}: cargoHash: {err}",
                            file=sys.stderr,
                        )
                    continue

                # --- сохраняем в кэш ---
                if not no_cache:
                    cache[key] = h
                    _cache_dirty = True
                    _cache_misses += 1

                new_snippet = CARGO_HASH_PLACEHOLDER_RE.sub(
                    f'cargoHash = "{h}";', snippet
                )
                text = text[:a_start] + new_snippet + text[a_end:]
                print(f"  ✓ {path}: {name}: cargoHash → {h}")
                changes.append(("cargoHash", "lib.fakeHash", h))

        if not check and text != original:
            with timed("  write_text"):
                path.write_text(text, encoding="utf-8")

        return changes


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
        help="сверять даже хэши в форме SRI (медленно, лезет в сеть)",
    )
    ap.add_argument(
        "--refresh-cache",
        action="store_true",
        help="игнорировать прочитанный кэш, пересчитать и перезаписать",
    )
    ap.add_argument(
        "--no-cache",
        action="store_true",
        help="не читать и не писать кэш",
    )
    ap.add_argument(
        "--no-cargo",
        action="store_true",
        help="не пытаться вычислять cargoHash (быстро)",
    )
    ap.add_argument(
        "--cargo-timeout",
        type=int,
        default=900,
        metavar="SEC",
        help="таймаут на один nix-build для cargoHash (по умолчанию 900)",
    )
    ap.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args()

    t_start = time.perf_counter()

    with timed("collect_files (caller)"):
        files = collect_files(args.paths)
    if not files:
        print("Нет .nix файлов для сканирования.", file=sys.stderr)
        return 1

    if not args.no_cargo:
        print(
            "[info] cargoHash включён: для блоков с `lib.fakeHash` будет запущен "
            "nix-build (или взят результат из кэша). Отключить: --no-cargo."
        )

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
                        no_cargo=args.no_cargo,
                        cargo_timeout=args.cargo_timeout,
                    )
                )
            except Exception as e:
                print(f"error: {f}: {e}", file=sys.stderr)

    if not args.no_cache:
        save_cache()

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
    elif args.verbose:
        print("Все хэши актуальны.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
