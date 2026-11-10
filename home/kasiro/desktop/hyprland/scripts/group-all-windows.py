#!/usr/bin/env python3
import json
import subprocess
import sys


def hypr_dispatch(lua_expr):
    """Отправляет Lua-выражение в Hyprland через hyprctl dispatch."""
    subprocess.run(["hyprctl", "dispatch", lua_expr], check=True, capture_output=True)


def get_clients():
    out = subprocess.check_output(["hyprctl", "clients", "-j"], text=True)
    return json.loads(out)


def get_active_workspace():
    out = subprocess.check_output(["hyprctl", "activeworkspace", "-j"], text=True)
    return json.loads(out)["id"]


def main():
    clients = get_clients()
    current_ws = get_active_workspace()

    # Ищем окна текущего рабочего стола, которые находятся в группе
    grouped_clients = [
        c
        for c in clients
        if c["workspace"]["id"] == current_ws
        and c.get("grouped")
        and len(c["grouped"]) > 0
    ]

    if not grouped_clients:
        print("На текущем рабочем столе нет сгруппированных окон.")
        return

    # Берём первое попавшееся сгруппированное окно как точку входа
    # (все окна одной группы имеют одинаковый список `grouped`)
    group_info = grouped_clients[0]["grouped"]
    # `grouped` — это список адресов окон в порядке их следования в группе
    addresses = [item["address"] for item in group_info]

    if len(addresses) < 2:
        return

    print(f"Разгруппировываю {len(addresses)} окон в обратном порядке...")

    # Извлекаем окна из группы по одному, начиная с последнего.
    # Каждое извлечённое окно добавляется в конец рабочего стола,
    # поэтому обратный порядок извлечения даёт правильный итоговый порядок.
    for addr in reversed(addresses):
        hypr_dispatch(f'hl.dsp.focus({{ window = "address:{addr}" }})')
        hypr_dispatch("hl.dsp.window.move({ out_of_group = true })")

    print("Готово.")


if __name__ == "__main__":
    main()
