#!/usr/bin/env python3
import json
import subprocess


def hypr_dispatch(lua_expr):
    """Отправляет Lua-выражение в Hyprland через hyprctl dispatch."""
    subprocess.run(["hyprctl", "dispatch", lua_expr], check=True, capture_output=True)


def get_clients():
    out = subprocess.check_output(["hyprctl", "clients", "-j"], text=True)
    return json.loads(out)


def get_active_workspace():
    out = subprocess.check_output(["hyprctl", "activeworkspace", "-j"], text=True)
    return json.loads(out)["id"]


def get_direction(from_win, to_win):
    """Определяет примерное направление (l/r/u/d) от одного окна к другому."""
    dx = to_win["at"][0] - from_win["at"][0]
    dy = to_win["at"][1] - from_win["at"][1]
    if abs(dx) > abs(dy):
        return "l" if dx < 0 else "r"
    else:
        return "u" if dy < 0 else "d"


def sort_windows_by_position(windows):
    """
    Сортирует окна по их визуальному положению:
    сначала по горизонтали (слева направо), затем по вертикали (сверху вниз).
    """
    # Сначала сортируем по X (слева направо), затем по Y (сверху вниз)
    return sorted(windows, key=lambda w: (w["at"][0], w["at"][1]))


def main():
    clients = get_clients()
    current_ws = get_active_workspace()
    ws_clients = [c for c in clients if c["workspace"]["id"] == current_ws]

    if len(ws_clients) < 2:
        return

    # Сортируем окна в желаемом порядке (например, слева направо, сверху вниз)
    ordered_clients = sort_windows_by_position(ws_clients)

    first = ordered_clients[0]
    first_addr = first["address"]

    # 1. Создаём группу из первого окна
    hypr_dispatch(f'hl.dsp.focus({{ window = "address:{first_addr}" }})')
    hypr_dispatch("hl.dsp.group.toggle()")

    # 2. Добавляем остальные окна в группу в отсортированном порядке
    for client in ordered_clients[1:]:
        addr = client["address"]

        # Фокусируемся на текущем окне
        hypr_dispatch(f'hl.dsp.focus({{ window = "address:{addr}" }})')

        # Определяем направление к первому окну (группе)
        direction = get_direction(client, first)

        # Перемещаем окно в группу в этом направлении
        hypr_dispatch(f'hl.dsp.window.move({{ into_group = "{direction}" }})')


if __name__ == "__main__":
    main()
