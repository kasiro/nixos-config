#!/usr/bin/env python3
"""
Умное перемещение окон в Sway (COSMIC-style).
- Left/Right: если окно на краю — переместить на prev/next workspace
- Up/Down: стандартное move up/down
"""

import sys
import logging
from pathlib import Path

import i3ipc

# Лог-файл в той же папке, где скрипт
script_dir = Path(__file__).parent
log_file = script_dir / "smart-move.log"

logging.basicConfig(
    filename=log_file,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)


def get_edge_direction(conn, direction):
    """Проверить, находится ли окно на краю в указанном направлении."""
    try:
        tree = conn.get_tree()
        focused = tree.find_focused()
        logging.debug(f"Focused window: {focused}")
        if not focused:
            logging.warning("No focused window found")
            return None

        # Получить все узлы в текущем workspace
        workspace = focused.workspace()
        if not workspace:
            logging.warning("No workspace found for focused window")
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
                        logging.debug("Has sibling: left")
                        return None  # Есть сосед слева, не на краю
            logging.debug("No sibling: left (edge)")
            return "prev"  # На краю — перейти на prev workspace

        elif direction == "right":
            nodes = workspace.leaves()
            current_rect = focused.rect
            for node in nodes:
                if node.id != focused.id:
                    node_rect = node.rect
                    # Узел справа, если его левый край >= правого края текущего
                    if node_rect.x >= current_rect.x + current_rect.width:
                        logging.debug("Has sibling: right")
                        return None  # Есть сосед справа
            logging.debug("No sibling: right (edge)")
            return "next"  # На краю — перейти на next workspace

        elif direction == "up":
            nodes = workspace.leaves()
            current_rect = focused.rect
            for node in nodes:
                if node.id != focused.id:
                    node_rect = node.rect
                    # Узел сверху, если его нижний край <= верхнего края текущего
                    if node_rect.y + node_rect.height <= current_rect.y:
                        logging.debug("Has sibling: up")
                        return None  # Есть сосед сверху
            logging.debug("No sibling: up (edge)")
            return "up"  # На краю — стандартное move up

        elif direction == "down":
            nodes = workspace.leaves()
            current_rect = focused.rect
            for node in nodes:
                if node.id != focused.id:
                    node_rect = node.rect
                    # Узел снизу, если его верхний край >= нижнего края текущего
                    if node_rect.y >= current_rect.y + current_rect.height:
                        logging.debug("Has sibling: down")
                        return None  # Есть сосед снизу
            logging.debug("No sibling: down (edge)")
            return "down"  # На краю — стандартное move down

        return None
    except Exception as e:
        logging.error(f"Error in get_edge_direction: {e}", exc_info=True)
        raise


def main():
    try:
        if len(sys.argv) != 2:
            msg = f"Использование: {sys.argv[0]} <left|right|up|down>"
            logging.error(msg)
            print(msg, file=sys.stderr)
            sys.exit(1)

        direction = sys.argv[1].lower()
        logging.info(f"Smart move started: direction={direction}")
        
        if direction not in ("left", "right", "up", "down"):
            msg = f"Неверное направление: {direction}"
            logging.error(msg)
            print(msg, file=sys.stderr)
            sys.exit(1)

        conn = i3ipc.Connection()
        edge_action = get_edge_direction(conn, direction)

        if edge_action is None:
            # Есть сосед — стандартное перемещение фокуса
            command = f"move {direction}"
            logging.info(f"Executing: {command}")
            conn.command(command)
        elif edge_action in ("prev", "next"):
            # Край по горизонтали — перейти на другой workspace с окном
            command = f"move container to workspace {edge_action}_on_output; workspace {edge_action}_on_output"
            logging.info(f"Executing: {command}")
            conn.command(command)
        else:
            # Край по вертикали — стандартное move up/down
            command = f"move {edge_action}"
            logging.info(f"Executing: {command}")
            conn.command(command)

        conn.close()
        logging.info("Smart move completed successfully")
    except Exception as e:
        logging.error(f"Error: {e}", exc_info=True)
        print(f"Ошибка: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
