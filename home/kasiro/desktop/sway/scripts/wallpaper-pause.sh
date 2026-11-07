#!/usr/bin/env bash
# Пауза видеообоев, когда на видимом workspace есть окно.
# Waybar, fuzzel, mako и сам mpvpaper — layer-shell, их в get_tree нет.

# Ждём пока mpvpaper создаст сокет и будет готов
sleep 3

SOCK="${MPV_SOCKET:-/tmp/mpv-socket}"
last=""

send() { printf '%s\n' "$1" | socat - UNIX-CONNECT:"$SOCK" >/dev/null 2>&1; }

state() {
  swaymsg -t get_tree | jq -r '
    [ .. | objects | select(.type? == "workspace" and .visible == true) ] as $ws
    | [ $ws[] | .. | objects | select((.pid? // 0) > 0) ]
    | if length > 0 then "pause" else "play" end'
}

apply() {
  local s; s="$(state)"
  [ -z "$s" ] && return
  [ "$s" = "$last" ] && return
  if [ "$s" = pause ]; then send 'set pause yes'; else send 'set pause no'; fi
  last="$s"
}

apply   # стартовое состояние — критично, иначе скрипт врёт о паузе до первого события

swaymsg -t subscribe -m '["window","workspace","output","mode"]' \
  | while read -r _; do apply; done
