#!/usr/bin/env python3
import json
import subprocess

# Получаем все окна на текущем workspace
result = subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True)
clients = json.loads(result.stdout)

# Получаем текущий workspace
ws_result = subprocess.run(
    ["hyprctl", "activeworkspace", "-j"], capture_output=True, text=True
)
current_ws = json.loads(ws_result.stdout)["id"]

# Фильтруем окна текущего workspace
ws_clients = [c for c in clients if c["workspace"]["id"] == current_ws]

if len(ws_clients) < 2:
    exit(0)

# Создаём группу из первого окна
first = ws_clients[0]["address"]
subprocess.run(
    ["hyprctl", "dispatch", f'hl.dsp.window.focus({{ address = "{first}" }})']
)
subprocess.run(["hyprctl", "dispatch", "hl.dsp.group.lock()"])

# Добавляем остальные окна в группу
for client in ws_clients[1:]:
    addr = client["address"]
    subprocess.run(
        ["hyprctl", "dispatch", f'hl.dsp.window.focus({{ address = "{addr}" }})']
    )
    subprocess.run(["hyprctl", "dispatch", 'hl.dsp.window.move_to_group("f")'])

# Возвращаемся на первое окно
subprocess.run(
    ["hyprctl", "dispatch", f'hl.dsp.window.focus({{ address = "{first}" }})']
)
subprocess.run(["hyprctl", "dispatch", "hl.dsp.group.unlock()"])
