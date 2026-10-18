#!/usr/bin/env python3
"""
Скрипт для rebuild NixOS конфигурации.
Заменяет fish-функцию rebuild с поддержкой prehook/posthook.
"""

import argparse
import subprocess
import signal
import sys
import os
import re
from pathlib import Path


def analyze_build():
    """
    Анализ предстоящей сборки NixOS.
    Запускает nh os switch . --dry-run и парсит вывод.
    """
    print("\n📦 Предстоящая сборка:")
    print("─" * 32)
    
    try:
        # Запускаем nh с --dry-run для получения информации
        result = subprocess.run(
            ["nh", "os", "switch", ".", "--dry-run"],
            capture_output=True,
            text=True,
            timeout=120
        )
        
        output = result.stdout + result.stderr
        
        # Парсим количество дериваций
        derivations_count = 0
        build_count = 0
        download_count = 0
        
        # Ищем паттерны в выводе nh/nix
        # Пример: "15 derivations to be built"
        deriv_match = re.search(r'(\d+)\s+derivations?\s+(?:to be )?built', output, re.IGNORECASE)
        if deriv_match:
            derivations_count = int(deriv_match.group(1))
        
        # Ищем что будет построено (build)
        build_match = re.search(r'(\d+)\s+(?:builder|build)s?\s+to\s+be', output, re.IGNORECASE)
        if build_match:
            build_count = int(build_match.group(1))
        
        # Ищем что будет скачано (download/cached)
        download_match = re.search(r'(\d+)\s+(?:download|cached|substituter)', output, re.IGNORECASE)
        if download_match:
            download_count = int(download_match.group(1))
        
        # Если не нашли явные build/download, пробуем альтернативный парсинг
        if derivations_count == 0:
            # Считаем все строки с путями к деривациям
            deriv_lines = [
                line for line in output.split('\n')
                if '/nix/store/' in line and ('.drv' in line or 'building' in line.lower())
            ]
            derivations_count = len(deriv_lines)
        
        # Вычисляем проценты
        if derivations_count > 0:
            if build_count == 0 and download_count == 0:
                # Если не нашли явных указаний, предполагаем что всё скачивается
                download_count = derivations_count
                build_count = 0
            
            build_pct = (build_count / derivations_count) * 100
            download_pct = (download_count / derivations_count) * 100
        else:
            build_pct = 0
            download_pct = 0
        
        # Пытаемся найти оценку времени
        time_estimate = None
        time_match = re.search(r'(?:estimated|approximate|ETA)[:\s]+(~?\s*\d+\s*(?:min|sec|hour))', output, re.IGNORECASE)
        if time_match:
            time_estimate = time_match.group(1).strip()
        
        # Вывод результатов
        print(f"Дериваций: {derivations_count}")
        print(f"Сборка из исходников: {build_count} ({build_pct:.0f}%)")
        print(f"Скачивание бинарников: {download_count} ({download_pct:.0f}%)")
        
        if time_estimate:
            print(f"Примерное время: {time_estimate}")
        else:
            # Грубая оценка: ~20 сек на сборку из исходников
            if build_count > 0:
                estimated_min = max(1, (build_count * 20) // 60)
                print(f"Примерное время: ~{estimated_min} мин (оценка)")
            else:
                print("Примерное время: <1 мин (только скачивание)")
        
        print("─" * 32)
        
    except FileNotFoundError:
        print("❌ Команда 'nh' не найдена. Установите nh или используйте nix-build.")
    except subprocess.TimeoutExpired:
        print("⚠ Таймаут анализа сборки (>120 сек)")
    except Exception as e:
        print(f"⚠ Ошибка анализа: {e}")


# Prehook функции - выполняются ДО rebuild
PREHOOKS = [
    "analyze_build",  # имя функции без скобок
]

# Posthook функции - выполняются ПОСЛЕ rebuild
POSTHOOKS = [
    # "command1",
    # "command2",
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

            print(f"\n>>> Executing {phase_name}: {hook}")
            
            # Проверяем: есть ли такое имя в globals() и это callable
            if hook in globals() and callable(globals()[hook]):
                # Это Python-функция
                try:
                    globals()[hook]()
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
        return True

    def has_changes(self):
        """Проверить наличие изменений в git."""
        try:
            result = subprocess.run(
                ["git", "diff", "--quiet"],
                capture_output=True,
                text=True
            )
            return result.returncode != 0
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

    def run_rebuild(self):
        """Запустить nh os switch с потоковым выводом."""
        rebuild_status = "FAIL"

        try:
            # Запускаем nh с потоковым выводом
            self.nh_process = subprocess.Popen(
                ["nh", "os", "switch", ".", "--log-format", "bar"],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )

            # Читаем вывод построчно в реальном времени
            if self.nh_process.stdout:
                for line in self.nh_process.stdout:
                    print(line, end='')
                    sys.stdout.flush()

            # Ждём завершения процесса
            returncode = self.nh_process.wait()
            rebuild_status = "OK" if returncode == 0 else "FAIL"

        except KeyboardInterrupt:
            self.interrupted = True
            if self.nh_process and self.nh_process.poll() is None:
                self.nh_process.terminate()
                try:
                    self.nh_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self.nh_process.kill()
            print("\n!!! Rebuild interrupted by user")
            rebuild_status = "FAIL"
            sys.exit(130)

        return rebuild_status

    def run(self):
        """Основная логика rebuild."""
        # Выполняем prehook
        if PREHOOKS:
            if not self.run_hooks(PREHOOKS, "Prehook"):
                print("\n!!! Prehook failed, aborting rebuild")
                sys.exit(1)

        # Коммитим изменения если есть
        committed = False
        if not self.args.no_commit and self.has_changes():
            committed = self.commit_changes(self.args.message)

        # Запускаем rebuild
        rebuild_status = self.run_rebuild()

        # Push если коммит был успешен
        if committed and not self.args.no_push:
            push_done = self.push_changes()
        else:
            push_done = False

        # Выполняем posthook
        if POSTHOOKS:
            self.run_hooks(POSTHOOKS, "Posthook")

        # Итоговый статус
        print(f"\nRebuild: {rebuild_status}")
        if self.args.no_push:
            print("Push: skipped (--no-push)")
        elif not committed:
            print("Push: not made (no commit)")
        else:
            print(f"Push: {'done' if push_done else 'failed'}")

        sys.exit(0 if rebuild_status == "OK" else 1)


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
