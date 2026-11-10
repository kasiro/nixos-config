#!/usr/bin/env python3
"""
Группировка всех окон на текущем workspace в одну группу (как в Sway i3-tabbed).
Использует hyprctl для получения информации об окнах и управления группами.

Работает по принципу:
1. Если текущее окно уже в группе — разгруппировать
2. Если нет — сгруппировать ВСЕ окна на текущем workspace
"""

import json
import subprocess
import sys


def hyprctl(command: str) -> str:
    """Выполнить hyprctl команду и вернуть вывод."""
    result = subprocess.run(
        ["hyprctl", "-j"] + command.split(),
        capture_output=True,
        text=True
    )
    return result.stdout.strip()


def get_active_window():
    """Получить информацию об активном окне."""
    output = hyprctl("activewindow")
    return json.loads(output) if output else None


def get_active_workspace():
    """Получить информацию о текущем workspace."""
    output = hyprctl("activeworkspace")
    return json.loads(output) if output else None


def get_clients():
    """Получить список всех окон (клиентов)."""
    output = hyprctl("clients")
    return json.loads(output) if output else []


def dispatch(command: str):
    """Выполнить dispatcher команду."""
    subprocess.run(["hyprctl", "dispatch"] + command.split(), check=False)


def group_all_windows():
    """Сгруппировать все окна на текущем workspace в одну группу."""
    active_window = get_active_window()
    if not active_window:
        print("Нет активного окна", file=sys.stderr)
        return

    # Проверяем, уже ли в группе
    if active_window.get("grouped"):
        # Уже в группе — разгруппировать
        dispatch("togglegroup")
        dispatch("layoutmsg swapwithmaster master")
        print("Окна разгруппированы")
        return

    active_workspace = get_active_workspace()
    if not active_workspace:
        print("Не удалось получить workspace", file=sys.stderr)
        return

    workspace_id = active_workspace.get("id")
    clients = get_clients()

    # Собираем все окна на текущем workspace
    windows = [c for c in clients if c.get("workspace", {}).get("id") == workspace_id]

    if len(windows) <= 1:
        print("Только одно окно на workspace, группировка не нужна")
        return

    # Получаем адрес активного окна для фокуса в конце
    active_address = active_window.get("address", "")

    # Создаём группу с первым окном
    first_address = windows[0].get("address")
    dispatch(f"focuswindow address:{first_address}")
    dispatch("togglegroup")

    # Добавляем остальные окна в группу
    for window in windows[1:]:
        address = window.get("address")
        if not address:
            continue

        # Фокусируемся на окне
        dispatch(f"focuswindow address:{address}")

        # Добавляем в группу (несколько направлений для надёжности)
        # В Hyprland moveintogroup добавляет окно в группу текущего фокуса
        for _ in range(2):  # Повторяем для надёжности на deep-layouts
            dispatch("moveintogroup l")
            dispatch("moveintogroup r")
            dispatch("moveintogroup u")
            dispatch("moveintogroup d")

    # Возвращаем фокус на активное окно
    if active_address:
        dispatch(f"focuswindow address:{active_address}")

    print(f"Сгруппировано {len(windows)} окон на workspace {workspace_id}")


def main():
    group_all_windows()


if __name__ == "__main__":
    main()
