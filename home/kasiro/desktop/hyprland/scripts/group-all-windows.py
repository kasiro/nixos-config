#!/usr/bin/env python3
"""
Toggle-группировка окон на активном рабочем столе Hyprland.

  - Если на workspace есть сгруппированные окна → разгруппировать все группы,
    сохраняя порядок окон (извлекаем по одному в обратном порядке).
  - Иначе → сгруппировать все окна workspace, сортируя их по визуальному
    положению (слева направо, сверху вниз).
"""

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


def sort_windows_by_position(windows):
    """Сортирует окна по визуальному положению (X, затем Y)."""
    return sorted(windows, key=lambda w: (w["at"][0], w["at"][1]))


def get_direction(from_win, to_win):
    """Направление (l/r/u/d) от одного окна к другому."""
    dx = to_win["at"][0] - from_win["at"][0]
    dy = to_win["at"][1] - from_win["at"][1]
    if abs(dx) > abs(dy):
        return "l" if dx < 0 else "r"
    return "u" if dy < 0 else "d"


def group_all(ws_clients):
    """Группирует все окна workspace в визуальном порядке."""
    if len(ws_clients) < 2:
        print("Недостаточно окон для группировки.")
        return

    ordered = sort_windows_by_position(ws_clients)
    first = ordered[0]

    hypr_dispatch(f'hl.dsp.focus({{ window = "address:{first["address"]}" }})')
    hypr_dispatch("hl.dsp.group.toggle()")

    for client in ordered[1:]:
        hypr_dispatch(f'hl.dsp.focus({{ window = "address:{client["address"]}" }})')
        direction = get_direction(client, first)
        hypr_dispatch(f'hl.dsp.window.move({{ into_group = "{direction}" }})')

    print(f"Сгруппировано {len(ordered)} окон.")


def ungroup_all(grouped_clients):
    """Разгруппировывает все группы workspace, сохраняя порядок окон в каждой."""
    # Группы идентифицируем по адресу первого окна в списке `grouped`.
    groups = {}
    for c in grouped_clients:
        addresses = [item["address"] for item in c["grouped"]]
        if len(addresses) < 2:
            continue
        groups.setdefault(addresses[0], addresses)

    if not groups:
        return

    total = 0
    for addresses in groups.values():
        # Извлекаем с конца: каждое окно уходит в конец workspace,
        # поэтому обратный порядок извлечения = прямой итоговый порядок.
        for addr in reversed(addresses):
            hypr_dispatch(f'hl.dsp.focus({{ window = "address:{addr}" }})')
            hypr_dispatch("hl.dsp.window.move({ out_of_group = true })")
        total += len(addresses)

    print(f"Разгруппировано {total} окон в {len(groups)} группе(ах).")


def main():
    clients = get_clients()
    current_ws = get_active_workspace()
    ws_clients = [c for c in clients if c["workspace"]["id"] == current_ws]

    grouped = [c for c in ws_clients if c.get("grouped")]

    if grouped:
        ungroup_all(grouped)
    else:
        group_all(ws_clients)


if __name__ == "__main__":
    main()
