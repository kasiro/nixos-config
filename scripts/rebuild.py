#!/usr/bin/env python3
"""
Скрипт для rebuild NixOS конфигурации.
Заменяет fish-функцию rebuild с поддержкой prehook/posthook.
"""

import argparse
import fcntl
import os
import pty
import re
import select
import signal
import struct
import subprocess
import sys
import termios
import time
from pathlib import Path

# Проекты: полная информация (путь + git URL).
# Используется в push_projects().
# Формат: {"path": "~...", "git": "https://..."}
PROJECTS = [
    {"path": "~/Документы/kasiro-proxy", "git": "https://github.com/kasiro/proxy"},
    {"path": "~/.config/opencode", "git": "https://github.com/kasiro/opencode-config"},
    {"path": "~/.agents/skills", "git": "https://github.com/kasiro/agents_skills_backup"},
    {"path": "~/.config/nvim", "git": "https://github.com/kasiro/nvim_config"},
    {"path": "~/Документы/dl", "git": "https://github.com/kasiro/dl"},
]


def stream_subprocess(cmd, *, env=None, stdin=None, on_start=None, prefix=None):
    """Запуск команды с выводом в реальном времени.

    Дочерний процесс получает pty в качестве stdout/stderr, поэтому считает
    вывод терминалом: libc/rust не включают блочную буферизацию (4-8 KiB) и
    nix не отключает прогресс-бар и цвета (`--log-format bar` работает только
    для TTY). Без pty (экзотическое окружение) — построчный pipe-фолбэк.

    Возвращает код возврата процесса.
    """
    if prefix:
        cmd = [*prefix, *cmd]

    if env is None:
        env = {**os.environ, "PYTHONUNBUFFERED": "1"}

    master_fd = None
    slave_fd = -1
    try:
        master_fd, slave_fd = pty.openpty()
    except OSError:
        master_fd = None

    # Фолбэк: обычный pipe + построчное чтение с явным flush.
    if master_fd is None:
        proc = subprocess.Popen(
            cmd,
            stdin=stdin,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            env=env,
        )
        if on_start:
            on_start(proc)
        try:
            if proc.stdout:
                for line in proc.stdout:
                    print(line, end="", flush=True)
        finally:
            if proc.stdout:
                proc.stdout.close()
        return proc.wait()

    # pty по умолчанию 80x24 — сообщаем реальный размер, иначе nix рисует
    # прогресс-бар неправильной ширины.
    try:
        size = os.get_terminal_size(sys.stdout.fileno())
        fcntl.ioctl(
            slave_fd,
            termios.TIOCSWINSZ,
            struct.pack("HHHH", size.lines, size.columns, 0, 0),
        )
    except OSError:
        pass

    # Отключаем OPOST: иначе pty превращает \n в \r\n и мусорит в
    # перенаправленном выводе (`rebuild.py > log.txt`). Прогресс-строки
    # с \r при этом продолжают работать.
    try:
        attrs = termios.tcgetattr(slave_fd)
        attrs[1] &= ~termios.OPOST
        termios.tcsetattr(slave_fd, termios.TCSANOW, attrs)
    except OSError:
        pass

    # stdin НЕ перенаправляем: интерактивные вопросы (nh) должны доходить
    # до настоящего терминала. pty нужен только для stdout/stderr.
    proc = subprocess.Popen(
        cmd,
        stdin=stdin,
        stdout=slave_fd,
        stderr=slave_fd,
        env=env,
        close_fds=True,
    )
    if on_start:
        on_start(proc)
    os.close(slave_fd)

    out = sys.stdout.buffer
    idle_ticks = 0
    try:
        while True:
            ready, _, _ = select.select([master_fd], [], [], 0.2)
            if ready:
                idle_ticks = 0
                try:
                    chunk = os.read(master_fd, 65536)
                except OSError:
                    # EIO — slave закрыт, вывод закончился.
                    break
                if not chunk:
                    break
                # Пишем байты как есть: \r прогресс-строк и ANSI-цвета
                # должны дойти до терминала без искажений.
                out.write(chunk)
                out.flush()
                continue
            if proc.poll() is not None:
                idle_ticks += 1
                # Процесс завершился, но pty не отдал EOF — не висим вечно.
                if idle_ticks >= 5:
                    break
    finally:
        try:
            os.close(master_fd)
        except OSError:
            pass

    return proc.wait()


def analyze_build():
    """
    Анализ предстоящей сборки NixOS.
    Запускает nh os switch . --dry-run и парсит вывод.
    """
    print("\n📦 Предстоящая сборка:")
    print("─" * 32)
    
    try:
        # Запускаем nh с --dry для получения информации
        result = subprocess.run(
            ["nh", "os", "switch", ".", "--dry"],
            capture_output=True,
            text=True,
            timeout=120
        )
        
        output = result.stdout + result.stderr
        
        # Парсим количество дериваций
        derivations_count = 0
        build_count = 0
        download_count = 0
        
        # Реальный формат вывода nh:
        # these 8 derivations will be built:
        #   /nix/store/xxx-foo.drv
        #   /nix/store/yyy-bar.drv
        deriv_match = re.search(r'these\s+(\d+)\s+derivations?\s+will be built', output, re.IGNORECASE)
        if deriv_match:
            derivations_count = int(deriv_match.group(1))
        
        # Если не нашли стандартный паттерн — считаем строки с .drv
        if derivations_count == 0:
            deriv_lines = [
                line for line in output.split('\n')
                if '/nix/store/' in line and '.drv' in line
            ]
            derivations_count = len(deriv_lines)
        
        # nh не различает явно build/download в dry-run
        # Считаем всё как "будет построено" (консервативная оценка)
        build_count = derivations_count
        download_count = 0
        
        # Вычисляем проценты
        if derivations_count > 0:
            build_pct = 100
            download_pct = 0
        else:
            build_pct = 0
            download_pct = 0
        
        # Вывод результатов
        print(f"Дериваций: {derivations_count}")
        print(f"Сборка из исходников: {build_count} ({build_pct:.0f}%)")
        print(f"Скачивание бинарников: {download_count} ({download_pct:.0f}%)")
        
        # Оценка: ~30 сек на деривацию
        if build_count > 0:
            estimated_sec = build_count * 30
            time_str = f"~{estimated_sec // 60} мин" if estimated_sec >= 60 else f"~{estimated_sec} сек"
        else:
            time_str = "<1 мин"
        
        print(f"Примерное время: {time_str} (оценка)")
        
        print("─" * 32)
        
    except FileNotFoundError:
        print("❌ Команда 'nh' не найдена. Установите nh или используйте nix-build.")
    except subprocess.TimeoutExpired:
        print("⚠ Таймаут анализа сборки (>120 сек)")
    except Exception as e:
        print(f"⚠ Ошибка анализа: {e}")


def flake_check():
    """
    Prehook: проверка конфига (nix flake check --no-build).
    Ловит несуществующие NixOS-опции на этапе eval (без долгой сборки).
    Выполняется в текущей рабочей директории — той же, что у nh os switch .
    Возвращает False, если проверка упала.
    """
    print("\n🔍 Prehook: nix flake check --no-build")
    print("─" * 32)

    try:
        returncode = stream_subprocess(["nix", "flake", "check", "--no-build", "--offline"])

        if returncode != 0:
            print(f"⚠ nix flake check завершился с кодом {returncode}")
            print("─" * 32)
            return False

        print("✓ Конфигурация прошла проверку")
        print("─" * 32)
        return True

    except FileNotFoundError:
        print("❌ Команда 'nix' не найдена. Установите nix.")
        return False
    except Exception as e:
        print(f"⚠ Ошибка prehook: {e}")
        return False


def push_projects():
    """
    Posthook: коммит и push изменений в проектах из PROJECTS.
    Для каждого пути: проверяем незакоммиченные изменения и ahead-коммиты,
    при необходимости коммитим, затем пушим.
    Провал одного проекта не прерывает остальные; функция возвращает None
    (не False), чтобы run_hooks не помечал весь posthook как упавший.
    """
    print("\n🚀 Posthook: push_projects")
    print("─" * 32)

    ok_count = 0
    fail_count = 0
    skip_count = 0

    for p in PROJECTS:
        path = Path(p["path"]).expanduser()

        if not path.is_dir():
            print(f"⚠ Папка не найдена, пропущено: {path}")
            skip_count += 1
            continue

        if not (path / ".git").exists():
            print(f"⚠ Не git-репозиторий, пропущено: {path}")
            skip_count += 1
            continue

        # Проект без remote не трогаем вовсе: ни add, ни commit — иначе
        # останется закоммиченное, которое некуда пушить.
        remotes = subprocess.run(
            ["git", "-C", str(path), "remote"],
            capture_output=True,
            text=True,
        )
        if remotes.returncode != 0 or remotes.stdout.strip() == "":
            print(f"⚠ remote не настроен, пропуск: {path}")
            skip_count += 1
            continue

        try:
            # 1. Проверяем незакоммиченные изменения
            status = subprocess.run(
                ["git", "-C", str(path), "status", "--porcelain"],
                capture_output=True,
                text=True,
            )
            if status.returncode != 0:
                print(f"❌ git status упал в {path}: {status.stderr.strip()}")
                fail_count += 1
                continue

            has_uncommitted = status.stdout.strip() != ""

            # 2. Проверяем ahead-коммиты (закоммичено, но не запушено)
            ahead = subprocess.run(
                ["git", "-C", str(path), "rev-list", "@{u}..HEAD"],
                capture_output=True,
                text=True,
            )
            # returncode != 0 означает отсутствие upstream — считаем ahead=0
            has_ahead = ahead.returncode == 0 and ahead.stdout.strip() != ""

            # 3. Если нет изменений и нет ahead — пропускаем
            if not has_uncommitted and not has_ahead:
                print(f"○ Нет изменений для push: {path}")
                skip_count += 1
                continue

            # 4. Коммитим только если есть незакоммиченные изменения
            if has_uncommitted:
                add_result = subprocess.run(
                    ["git", "-C", str(path), "add", "."],
                    capture_output=True,
                    text=True,
                )
                if add_result.returncode != 0:
                    err = (add_result.stderr or add_result.stdout).strip()
                    print(f"❌ git add упал в {path}: {err}")
                    fail_count += 1
                    continue

                commit_result = subprocess.run(
                    ["git", "-C", str(path), "commit", "-m", "push"],
                    capture_output=True,
                    text=True,
                )
                if commit_result.returncode != 0:
                    err = (commit_result.stderr or commit_result.stdout).strip()
                    print(f"❌ git commit упал в {path}: {err}")
                    fail_count += 1
                    continue

            # 5. Push делаем всегда (либо новый коммит, либо ahead)
            push_result = subprocess.run(
                ["git", "-C", str(path), "push"],
                capture_output=True,
                text=True,
            )
            if push_result.returncode != 0:
                err = (push_result.stderr or push_result.stdout).strip()
                print(f"❌ git push упал в {path}: {err}")
                fail_count += 1
                continue

            print(f"✓ Запушено: {path}")
            ok_count += 1

        except Exception as e:
            print(f"❌ Ошибка в {path}: {e}")
            fail_count += 1

    print(f"Итог: ок {ok_count}, с ошибками {fail_count}, пропущено {skip_count}")
    print("─" * 32)
    return None


# Prehook функции - выполняются ДО rebuild
PREHOOKS = [
    # "flake_check",  # отключено
    # "analyze_build",  # временно отключено
]

# Posthook функции - выполняются ПОСЛЕ rebuild
POSTHOOKS = [
    "push_projects",
]


class RebuildProcess:
    """Управление процессом rebuild с обработкой прерываний."""

    def __init__(self, args):
        self.args = args
        self.nh_process = None
        self.interrupted = False

    def run_hooks(self, hooks, phase_name):
        """Выполнить список хуков. Возвращает True если все успешны."""
        if not hooks:
            return True

        for hook in hooks:
            hook = hook.strip()
            if not hook:
                continue

            print(f"\n> Executing {phase_name}: {hook}")

            t0 = time.perf_counter()
            try:
                # Проверяем: есть ли такое имя в globals() и это callable
                if hook in globals() and callable(globals()[hook]):
                    # Это Python-функция
                    try:
                        ok = globals()[hook]()
                        # Функция может явно сообщить о провале
                        if ok is False:
                            print(f"\n!!! {phase_name} '{hook}' failed")
                            if phase_name == "Prehook":
                                return False
                    except Exception as e:
                        print(f"\n!!! {phase_name} '{hook}' failed: {e}")
                        if phase_name == "Prehook":
                            return False
                else:
                    # Это shell-команда
                    try:
                        result = subprocess.run(
                            hook,
                            shell=True,
                            check=True,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT,
                            text=True
                        )
                        if result.stdout:
                            print(result.stdout, end='')
                    except subprocess.CalledProcessError as e:
                        print(f"\n!!! {phase_name} '{hook}' failed with code {e.returncode}")
                        if phase_name == "Prehook":
                            return False
            finally:
                dt = time.perf_counter() - t0
                if dt >= 60:
                    print(f"⏱ {hook}: {int(dt // 60)} мин {dt % 60:.2f}s")
                else:
                    print(f"⏱ {hook}: {dt:.2f}s")
        return True

    def has_changes(self):
        """Проверить наличие изменений в git (tracked + untracked)."""
        try:
            result = subprocess.run(
                ["git", "status", "--porcelain"],
                capture_output=True,
                text=True
            )
            return result.stdout.strip() != ""
        except Exception:
            return False

    def commit_changes(self, message):
        """Сделать коммит изменений. Возвращает True если коммит успешен."""
        if self.args.no_commit:
            return False

        if not self.has_changes():
            return False

        try:
            subprocess.run(["git", "add", "."], check=True)
            subprocess.run(["git", "commit", "-m", message], check=True)
            return True
        except subprocess.CalledProcessError:
            return False

    def push_changes(self):
        """Сделать push изменений."""
        if self.args.no_push:
            return False

        try:
            subprocess.run(["git", "push"], check=True)
            return True
        except subprocess.CalledProcessError:
            return False

    def _terminate(self):
        """Погасить дочерний процесс rebuild."""
        proc = self.nh_process
        if proc and proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()

    def run_rebuild(self):
        """Запустить nh os switch с потоковым выводом."""
        rebuild_status = "FAIL"

        try:
            # Запускаем nh с потоковым выводом через pty (см. stream_subprocess):
            # nix считает вывод TTY и не буферизует его блоками.
            t0 = time.perf_counter()
            returncode = stream_subprocess(
                ["nh", "os", "switch", ".", "--log-format", "bar"],
                prefix=None,
                on_start=lambda p: setattr(self, "nh_process", p),
            )
            rebuild_status = "OK" if returncode == 0 else "FAIL"

            total = time.perf_counter() - t0
            if total >= 60:
                print(f"\n⏱ Rebuild: {int(total // 60)} мин {total % 60:.2f}s")
            else:
                print(f"\n⏱ Rebuild: {total:.2f}s")

        except KeyboardInterrupt:
            self.interrupted = True
            self._terminate()
            print("\n!!! Rebuild interrupted by user")
            rebuild_status = "FAIL"
            sys.exit(130)
        except SystemExit:
            # SIGINT перехвачен signal_handler в main() → выходит SystemExit,
            # а не KeyboardInterrupt. Дочерний процесс всё равно гасим.
            self.interrupted = True
            self._terminate()
            raise
        except Exception as e:
            # Сборка не запустилась/упала нестандартно (нет nh, ошибка pty и т.п.).
            # Явно помечаем FAIL — push после такого недопустим.
            print(f"\n!!! Rebuild failed to run: {e}")
            rebuild_status = "FAIL"

        return rebuild_status

    def run(self):
        """Основная логика rebuild.

        Порядок: коммит → prehook → rebuild → posthook → push.
        """
        # Коммитим изменения если есть
        committed = False
        if not self.args.no_commit and self.has_changes():
            committed = self.commit_changes(self.args.message)

        # Выполняем prehook (после коммита, до любых действий с системой, в т.ч. при dry-run)
        if PREHOOKS:
            if not self.run_hooks(PREHOOKS, "Prehook"):
                print("\n❌ Prehook упал, переключение отменено")
                sys.exit(1)

        # Запускаем rebuild
        rebuild_status = self.run_rebuild()

        # Выполняем posthook (до push)
        if POSTHOOKS:
            self.run_hooks(POSTHOOKS, "Posthook")

        # ГЛАВНОЕ ПРАВИЛО: push разрешён ТОЛЬКО после успешной сборки.
        # Ненулевой код / исключение / прерывание → FAIL и выход, без push.
        if rebuild_status != "OK":
            print("\n❌ Сборка/переключение упали — push пропущен")
            print(f"\nRebuild: {rebuild_status}")
            print("Push: skipped (build failed)")
            sys.exit(1)

        # Push если коммит был успешен (последнее действие перед итоговым статусом)
        if committed and not self.args.no_push:
            push_done = self.push_changes()
        else:
            push_done = False

        # Итоговый статус
        print(f"\nRebuild: {rebuild_status}")
        if self.args.no_push:
            print("Push: skipped (--no-push)")
        elif not committed:
            print("Push: not made (no commit)")
        else:
            print(f"Push: {'done' if push_done else 'failed'}")

        sys.exit(0)


def main():
    parser = argparse.ArgumentParser(
        description="Rebuild NixOS конфигурации с поддержкой хуков"
    )
    parser.add_argument(
        "-m", "--message",
        default="rebuild",
        help="Сообщение коммита (по умолчанию: rebuild)"
    )
    parser.add_argument(
        "--no-commit",
        action="store_true",
        help="Не делать коммит"
    )
    parser.add_argument(
        "--no-push",
        action="store_true",
        help="Не делать push"
    )

    args = parser.parse_args()

    # Обработка SIGINT (Ctrl+C)
    def signal_handler(signum, frame):
        print("\n!!! Interrupted by user")
        sys.exit(130)

    signal.signal(signal.SIGINT, signal_handler)

    process = RebuildProcess(args)
    process.run()


if __name__ == "__main__":
    main()
