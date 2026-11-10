#!/usr/bin/env python3
import json
import subprocess


def hypr_dispatch(lua_expr):
    subprocess.run(["hyprctl", "dispatch", lua_expr], check=True, capture_output=True)


def get_clients():
    out = subprocess.check_output(["hyprctl", "clients", "-j"], text=True)
    return json.loads(out)


def get_active_workspace():
    out = subprocess.check_output(["hyprctl", "activeworkspace", "-j"], text=True)
    return json.loads(out)["id"]


def sort_windows_by_position(windows):
    return sorted(windows, key=lambda w: (w["at"][0], w["at"][1]))


def get_direction(from_win, to_win):
    dx = to_win["at"][0] - from_win["at"][0]
    dy = to_win["at"][1] - from_win["at"][1]
    if abs(dx) > abs(dy):
        return "l" if dx < 0 else "r"
    return "u" if dy < 0 else "d"


def group_all(ws_clients):
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
    # Собираем уникальные группы по набору адресов.
    # Поле `grouped` — это список строк (адресов), а не словарей.
    groups = {}
    for c in grouped_clients:
        addresses = c["grouped"]  # <-- исправление: просто список строк
        if len(addresses) < 2:
            continue
        # Ключом группы может служить отсортированный кортеж адресов,
        # чтобы одно и то же окно не обрабатывалось дважды.
        key = tuple(sorted(addresses))
        groups.setdefault(key, addresses)

    if not groups:
        print("Групп для разгруппировки не найдено.")
        return

    total = 0
    for addresses in groups.values():
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
