#!/usr/bin/env python3
"""Ротация обоев Sway: один запуск — одна смена обоев и выход.

Настройки берутся из переменных окружения (их задаёт systemd-юнит):
  SWAY_WALLPAPER_DIR       — папка с обоями
  SWAY_WALLPAPER_DAY_ONLY  — имена файлов «только днём» через «:»
  SWAY_WALLPAPER_EXCLUDE   — имена файлов «никогда» через «:»
  SWAY_WALLPAPER_OUTPUT    — output для swaymsg (по умолчанию «*»)
  SWAY_WALLPAPER_MODE      — fill / fit / center / stretch / tile
  SWAY_WALLPAPER_DAY_START — начало дня, час (по умолчанию 10)
  SWAY_WALLPAPER_DAY_END   — конец дня, час (по умолчанию 20)
  SWAYMSG                  — путь к swaymsg (иначе ищем в PATH и типовых местах)
"""

import os
import random
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MODES = {"fill", "fit", "center", "stretch", "tile"}

# Так swaymsg сообщает, что Sway-сессии нет — это не ошибка таймера.
SWAY_UNAVAILABLE_MARKERS = (
    "Unable to retrieve socket path",
    "Failed to connect",
    "No such file",
)


def read_env(name, default=""):
    """Значение переменной окружения; пустая строка считается отсутствием."""
    value = os.environ.get(name)
    return value if value else default


def split_names(value):
    """Разбирает список имён через «:», отбрасывая пустые элементы."""
    return [part for part in value.split(":") if part]


def find_swaymsg():
    """Возвращает (путь, None) либо (None, сообщение об ошибке)."""
    configured = read_env("SWAYMSG")
    if configured:
        # SWAYMSG задан явно: несуществующий путь — ошибка конфигурации.
        if Path(configured).is_file() and os.access(configured, os.X_OK):
            return configured, None
        return None, f"swaymsg не найден: {configured}"

    found = shutil.which("swaymsg")
    if found:
        return found, None

    for candidate in (
        "/run/current-system/sw/bin/swaymsg",
        str(Path.home() / ".nix-profile/bin/swaymsg"),
    ):
        if Path(candidate).is_file() and os.access(candidate, os.X_OK):
            return candidate, None

    return None, "swaymsg не найден ни в PATH, ни в типовых местах"


def is_daytime(now, start, end):
    """День — интервал [start, end) по часам; поддерживает переход через полночь."""
    if start <= end:
        return start <= now.hour < end
    return now.hour >= start or now.hour < end


def collect_images(directory):
    """Все изображения в папке (без рекурсии)."""
    return sorted(
        (
            path
            for path in directory.iterdir()
            if path.is_file() and path.suffix.lower() in EXTENSIONS
        ),
        key=lambda path: path.name,
    )


def choose_image(images, day_only, exclude, daytime, previous):
    """Выбирает обои с учётом исключений и без повтора предыдущего файла."""
    filtered = [path for path in images if path.name not in exclude]
    if daytime:
        available = filtered
    else:
        available = [path for path in filtered if path.name not in day_only]

    if not available:
        # Мягкий фолбэк: не оставляем экран без обоев, но предупреждаем.
        print(
            "ВНИМАНИЕ: после фильтрации не осталось обоев, используется весь список",
            file=sys.stderr,
        )
        available = list(images)

    # Антиповтор: сначала пробуем всё, кроме предыдущего файла.
    pool = [path for path in available if path.name != previous] or available
    return random.choice(pool)


def state_path():
    """Файл с именем предыдущих обоев."""
    cache_home = read_env("XDG_CACHE_HOME", str(Path.home() / ".cache"))
    return Path(cache_home).expanduser() / "sway-wallpaper" / "last"


def read_previous(path):
    try:
        return path.read_text(encoding="utf-8").strip()
    except OSError:
        return ""


def write_previous(path, name):
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(name + "\n", encoding="utf-8")
    except OSError as exc:
        print(f"ВНИМАНИЕ: не удалось сохранить состояние: {exc}", file=sys.stderr)


def main():
    day_only = set(split_names(read_env("SWAY_WALLPAPER_DAY_ONLY")))
    exclude = set(split_names(read_env("SWAY_WALLPAPER_EXCLUDE")))
    output = read_env("SWAY_WALLPAPER_OUTPUT", "*")
    mode = read_env("SWAY_WALLPAPER_MODE", "fill")

    if mode not in MODES:
        print(
            f"Ошибка: недопустимый режим «{mode}», ожидается один из: "
            f"{', '.join(sorted(MODES))}",
            file=sys.stderr,
        )
        return 1

    try:
        day_start = int(read_env("SWAY_WALLPAPER_DAY_START", "10"))
        day_end = int(read_env("SWAY_WALLPAPER_DAY_END", "20"))
    except ValueError:
        print("Ошибка: границы дня должны быть целыми часами", file=sys.stderr)
        return 1

    directory = Path(
        read_env("SWAY_WALLPAPER_DIR", str(Path.home() / "Загрузки/wallpapers"))
    ).expanduser()
    if not directory.is_dir():
        print(f"Ошибка: папка с обоями не найдена: {directory}", file=sys.stderr)
        return 1

    images = collect_images(directory)
    if not images:
        print(f"Ошибка: в папке нет изображений: {directory}", file=sys.stderr)
        return 1

    swaymsg, error = find_swaymsg()
    if swaymsg is None:
        # Явно заданный, но битый путь — ошибка конфигурации (код 1),
        # полностью отсутствующий swaymsg — просто нет Sway (код 0).
        if read_env("SWAYMSG"):
            print(f"Ошибка: {error}", file=sys.stderr)
            return 1
        print(f"Пропуск: {error}", file=sys.stderr)
        return 0

    now = datetime.now()
    daytime = is_daytime(now, day_start, day_end)
    saved = state_path()
    previous = read_previous(saved)

    chosen = choose_image(images, day_only, exclude, daytime, previous)

    result = subprocess.run(
        [swaymsg, "output", output, "bg", str(chosen), mode],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        stderr = (result.stderr or "").strip()
        if any(marker in stderr for marker in SWAY_UNAVAILABLE_MARKERS):
            # Sway не запущен (например, после выхода из сессии) — тихо выходим.
            print(f"Пропуск: Sway недоступен: {stderr}", file=sys.stderr)
            return 0
        print(
            f"Ошибка: swaymsg завершился с кодом {result.returncode}: {stderr}",
            file=sys.stderr,
        )
        return 1

    write_previous(saved, chosen.name)

    period = "день" if daytime else "ночь"
    print(f"{now.strftime('%Y-%m-%d %H:%M:%S')} {chosen.name} ({period})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
