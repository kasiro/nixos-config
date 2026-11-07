#!/usr/bin/env bash
# Умная пауза mpvpaper: ставит на паузу, если на активном workspace есть окна

SOCKET="/tmp/mpv-socket"
PAUSED=0

send_cmd() {
  [ -S "$SOCKET" ] && echo "$1" | socat - "$SOCKET" >/dev/null 2>&1
}

# Подписываемся на события окон и рабочих столов
swaymsg -t subscribe '["window","workspace"]' -m | while read -r _; do
  # Считаем окна на активном workspace
  count=$(swaymsg -t get_tree | jq '
    .. | select(.type? == "workspace" and .focused == true) |
    .. | select(.type? == "window") | .id
  ' | wc -l)

  if [ "$count" -gt 0 ] && [ "$PAUSED" -eq 0 ]; then
    send_cmd "set pause yes"
    PAUSED=1
  elif [ "$count" -eq 0 ] && [ "$PAUSED" -eq 1 ]; then
    send_cmd "set pause no"
    PAUSED=0
  fi
done
