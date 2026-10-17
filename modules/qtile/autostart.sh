#!/bin/sh

# Переключение раскладки на Shift+Alt
setxkbmap -layout us,ru -option grp:shift_alt_toggle

# Запуск picom (композиционер для эффектов)
picom --config ~/.config/picom/picom.conf &

# Запуск других приложений (раскомментируй что нужно)
nm-applet &
blueman-applet &
clipit &
