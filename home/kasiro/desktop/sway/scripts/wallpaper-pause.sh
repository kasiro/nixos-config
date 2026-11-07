#!/usr/bin/env bash
# Умная пауза mpvpaper: ставит на паузу, если есть focused окно
# Игнорирует layer-shell поверхности (waybar, mako, mpvpaper)

SOCKET="/tmp/mpv-socket"
PAUSED=0

send_cmd() {
  [ -S "$SOCKET" ] && echo "$1" | socat - "$SOCKET" >/dev/null 2>&1
}

swaymsg -t subscribe '["window","workspace"]' -m | while read -r _; do
  # Считаем только focused обычные окна (con/floating_con) с app_id
  count=$(swaymsg -t get_tree | jq '
    .. | select(.type? == "con" or .type? == "floating_con") |
    select(.app_id != null and .app_id != "" and .focused == true) |
    .id
  ' | wc -l)

  if [ "$count" -gt 0 ] && [ "$PAUSED" -eq 0 ]; then
    send_cmd "set pause yes"
    PAUSED=1
  elif [ "$count" -eq 0 ] && [ "$PAUSED" -eq 1 ]; then
    send_cmd "set pause no"
    PAUSED=0
  fi
done
