#!/usr/bin/env python3
import json
import subprocess


def hypr_dispatch(lua_expr):
    """Отправляет Lua-выражение в Hyprland через hyprctl dispatch."""
    subprocess.run(["hyprctl", "dispatch", lua_expr], check=True)


# Получаем все окна на текущем workspace
result = subprocess.run(
    ["hyprctl", "clients", "-j"], capture_output=True, text=True, check=True
)
clients = json.loads(result.stdout)

# Получаем текущий workspace
ws_result = subprocess.run(
    ["hyprctl", "activeworkspace", "-j"], capture_output=True, text=True, check=True
)
current_ws = json.loads(ws_result.stdout)["id"]

# Фильтруем окна текущего workspace
ws_clients = [c for c in clients if c["workspace"]["id"] == current_ws]

if len(ws_clients) < 2:
    exit(0)

first = ws_clients[0]["address"]

# Фокусируемся на первом окне и блокируем группу
hypr_dispatch(f'hl.dsp.focus({{ window = "address:{first}" }})')
hypr_dispatch("hl.dsp.group.lock()")

# Добавляем остальные окна в группу
for client in ws_clients[1:]:
    addr = client["address"]
    hypr_dispatch(f'hl.dsp.focus({{ window = "address:{addr}" }})')
    hypr_dispatch("hl.dsp.group.move_window({ forward = true })")

# Возвращаемся на первое окно и разблокируем группу
hypr_dispatch(f'hl.dsp.focus({{ window = "address:{first}" }})')
hypr_dispatch('hl.dsp.group.lock({ action = "disable" })')
