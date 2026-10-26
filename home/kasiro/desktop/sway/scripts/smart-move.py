#!/usr/bin/env python3
"""
Умное перемещение окон в Sway (COSMIC-style).
- Left/Right: если окно на краю — переместить на соседний (в т.ч. новый) workspace
- Up/Down: стандартное move up/down
"""

# ПЕРВЫЕ СТРОКИ - логирование до любых импортов
import os
import sys
from pathlib import Path

# Абсолютный путь для лога
LOG_FILE = "/tmp/smart-move.log"


# Простое логирование без logging модуля
def log(msg):
    try:
        with open(LOG_FILE, "a") as f:
            f.write(f"{msg}\n")
    except:
        pass


log("=== Script started ===")
log(f"Python: {sys.executable}")
log(f"PATH: {os.environ.get('PATH', 'N/A')}")

# Теперь импорты
try:
    import i3ipc

    log("i3ipc imported successfully")
except ImportError as e:
    log(f"FATAL: i3ipc not found: {e}")
    sys.exit(1)


def get_edge_direction(conn, direction):
    """Проверить, находится ли окно на краю в указанном направлении."""
    try:
        tree = conn.get_tree()
        focused = tree.find_focused()
        log(f"Focused window: {focused}")
        if not focused:
            log("WARNING: No focused window found")
            return None

        # Получить все узлы в текущем workspace
        workspace = focused.workspace()
        if not workspace:
            log("WARNING: No workspace found for focused window")
            return None

        # Проверить, есть ли соседи в указанном направлении
        if direction == "left":
            # Проверить, есть ли узлы слева от текущего
            nodes = workspace.leaves()
            current_rect = focused.rect
            for node in nodes:
                if node.id != focused.id:
                    node_rect = node.rect
                    # Узел слева, если его правый край <= левого края текущего
                    if node_rect.x + node_rect.width <= current_rect.x:
                        log("Has sibling: left")
                        return None  # Есть сосед слева, не на краю
            log("No sibling: left (edge)")
            return "prev"  # На краю — перейти на prev workspace

        elif direction == "right":
            nodes = workspace.leaves()
            current_rect = focused.rect
            for node in nodes:
                if node.id != focused.id:
                    node_rect = node.rect
                    # Узел справа, если его левый край >= правого края текущего
                    if node_rect.x >= current_rect.x + current_rect.width:
                        log("Has sibling: right")
                        return None  # Есть сосед справа
            log("No sibling: right (edge)")
            return "next"  # На краю — перейти на next workspace

        # elif direction == "up":
        #     nodes = workspace.leaves()
        #     current_rect = focused.rect
        #     for node in nodes:
        #         if node.id != focused.id:
        #             node_rect = node.rect
        #             # Узел сверху, если его нижний край <= верхнего края текущего
        #             if node_rect.y + node_rect.height <= current_rect.y:
        #                 log("Has sibling: up")
        #                 return None  # Есть сосед сверху
        #     log("No sibling: up (edge)")
        #     return "up"  # На краю — стандартное move up

        # elif direction == "down":
        #     nodes = workspace.leaves()
        #     current_rect = focused.rect
        #     for node in nodes:
        #         if node.id != focused.id:
        #             node_rect = node.rect
        #             # Узел снизу, если его верхний край >= нижнего края текущего
        #             if node_rect.y >= current_rect.y + current_rect.height:
        #                 log("Has sibling: down")
        #                 return None  # Есть сосед снизу
        #     log("No sibling: down (edge)")
        #     return "down"  # На краю — стандартное move down

        return None
    except Exception as e:
        log(f"ERROR in get_edge_direction: {e}")
        raise


def get_output_name(node):
    """Имя output, которому принадлежит узел (output — родитель workspace)."""
    while node is not None and node.type != "output":
        node = node.parent
    return node.name if node is not None else None


def get_target_workspace_number(tree, workspace, direction):
    """Номер workspace, на который уходит окно за краем в direction.

    Sway создаёт workspace по `workspace number N`, если его ещё нет,
    поэтому right всегда даёт current + 1. Left от первого workspace
    заворачивается на последний существующий workspace своего output.
    Номера, занятые workspace'ом другого output, пропускаются: иначе
    `workspace number N` увёл бы фокус (и окно) на другой монитор.
    Возвращает None, если номер применить нельзя (именованный workspace,
    нет соседей для wrap) — тогда используется *_on_output.
    """
    if workspace is None or workspace.num is None or workspace.num < 1:
        return None

    output = get_output_name(workspace)
    workspaces = tree.workspaces()
    step = 1 if direction == "right" else -1
    target = workspace.num + step

    while target >= 1 and any(
        ws.num == target and get_output_name(ws) != output for ws in workspaces
    ):
        target += step

    if target >= 1:
        return target

    # Left от первого workspace: wrap на последний существующий на этом output.
    numbers = [
        ws.num
        for ws in workspaces
        if ws.num is not None and ws.num > 0 and get_output_name(ws) == output
    ]
    return max(numbers) if numbers else None


def main():
    try:
        if len(sys.argv) != 2:
            msg = f"Использование: {sys.argv[0]} <left|right|up|down>"
            log(f"ERROR: {msg}")
            print(msg, file=sys.stderr)
            sys.exit(1)

        direction = sys.argv[1].lower()
        log(f"Smart move started: direction={direction}")

        if direction not in ("left", "right"):
            msg = f"Неверное направление: {direction}"
            log(f"ERROR: {msg}")
            print(msg, file=sys.stderr)
            sys.exit(1)

        conn = i3ipc.Connection()
        edge_action = get_edge_direction(conn, direction)

        if edge_action is None:
            # Есть сосед — стандартное перемещение фокуса
            command = f"move {direction}"
            log(f"Executing: {command}")
            conn.command(command)
        elif edge_action in ("prev", "next"):
            # Край по горизонтали — уйти на соседний workspace (в т.ч. новый).
            # prev/next_on_output видят только существующие workspace, поэтому
            # для числовых workspace адресуем соседа по номеру.
            tree = conn.get_tree()
            focused = tree.find_focused()
            workspace = focused.workspace() if focused else None
            target = get_target_workspace_number(tree, workspace, direction)
            if target is None:
                command = f"move container to workspace {edge_action}_on_output; workspace {edge_action}_on_output"
            else:
                command = f"move container to workspace number {target}; workspace number {target}"
            log(f"Executing: {command}")
            conn.command(command)
        # else:
        #     # Край по вертикали — стандартное move up/down
        #     command = f"move {edge_action}"
        #     log(f"Executing: {command}")
        #     conn.command(command)

        conn.close()
        log("Smart move completed successfully")
    except Exception as e:
        log(f"ERROR: {e}")
        print(f"Ошибка: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
