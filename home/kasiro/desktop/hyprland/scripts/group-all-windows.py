#!/usr/bin/env python3
import json
import subprocess


def hypr_dispatch(lua_expr):
    """Отправляет Lua-выражение в Hyprland через hyprctl dispatch."""
    subprocess.run(["hyprctl", "dispatch", lua_expr], check=True)


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


def main():
    clients = get_clients()
    current_ws = get_active_workspace()
    ws_clients = [c for c in clients if c["workspace"]["id"] == current_ws]

    if len(ws_clients) < 2:
        return

    first = ws_clients[0]
    first_addr = first["address"]

    # 1. Создаём группу из первого окна
    hypr_dispatch(f'hl.dsp.focus({{ window = "address:{first_addr}" }})')
    hypr_dispatch("hl.dsp.group.toggle()")

    # 2. Добавляем остальные окна в группу
    for client in ws_clients[1:]:
        addr = client["address"]

        # Фокусируемся на текущем окне
        hypr_dispatch(f'hl.dsp.focus({{ window = "address:{addr}" }})')

        # Определяем направление к первому окну (группе)
        direction = get_direction(client, first)

        # Перемещаем окно в группу в этом направлении
        hypr_dispatch(f'hl.dsp.window.move({{ into_group = "{direction}" }})')


if __name__ == "__main__":
    main()
