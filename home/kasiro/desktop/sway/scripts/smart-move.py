#!/usr/bin/env python3
"""
Умное перемещение окон в Sway (COSMIC-style).
- Left/Right: если окно на краю — переместить на prev/next workspace
- Up/Down: стандартное move up/down
"""

import sys
import i3ipc


def get_edge_direction(conn, direction):
    """Проверить, находится ли окно на краю в указанном направлении."""
    tree = conn.get_tree()
    focused = tree.find_focused()
    if not focused:
        return None

    # Получить все узлы в текущем workspace
    workspace = focused.workspace()
    if not workspace:
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
                    return None  # Есть сосед слева, не на краю
        return "prev"  # На краю — перейти на prev workspace

    elif direction == "right":
        nodes = workspace.leaves()
        current_rect = focused.rect
        for node in nodes:
            if node.id != focused.id:
                node_rect = node.rect
                # Узел справа, если его левый край >= правого края текущего
                if node_rect.x >= current_rect.x + current_rect.width:
                    return None  # Есть сосед справа
        return "next"  # На краю — перейти на next workspace

    elif direction == "up":
        nodes = workspace.leaves()
        current_rect = focused.rect
        for node in nodes:
            if node.id != focused.id:
                node_rect = node.rect
                # Узел сверху, если его нижний край <= верхнего края текущего
                if node_rect.y + node_rect.height <= current_rect.y:
                    return None  # Есть сосед сверху
        return "up"  # На краю — стандартное move up

    elif direction == "down":
        nodes = workspace.leaves()
        current_rect = focused.rect
        for node in nodes:
            if node.id != focused.id:
                node_rect = node.rect
                # Узел снизу, если его верхний край >= нижнего края текущего
                if node_rect.y >= current_rect.y + current_rect.height:
                    return None  # Есть сосед снизу
        return "down"  # На краю — стандартное move down

    return None


def main():
    if len(sys.argv) != 2:
        print(f"Использование: {sys.argv[0]} <left|right|up|down>", file=sys.stderr)
        sys.exit(1)

    direction = sys.argv[1].lower()
    if direction not in ("left", "right", "up", "down"):
        print(f"Неверное направление: {direction}", file=sys.stderr)
        sys.exit(1)

    conn = i3ipc.Connection()
    edge_action = get_edge_direction(conn, direction)

    if edge_action is None:
        # Есть сосед — стандартное перемещение фокуса
        conn.command(f"move {direction}")
    elif edge_action in ("prev", "next"):
        # Край по горизонтали — перейти на другой workspace с окном
        conn.command(f"move container to workspace {edge_action}_on_output; workspace {edge_action}_on_output")
    else:
        # Край по вертикали — стандартное move up/down
        conn.command(f"move {edge_action}")

    conn.close()


if __name__ == "__main__":
    main()
