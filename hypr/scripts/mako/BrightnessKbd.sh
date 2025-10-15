#!/bin/bash

get_kbd_backlight() {
  brightnessctl -d '*::kbd_backlight' -m | cut -d, -f4
}

get_icon() {
  current=$(get_kbd_backlight | sed 's/%//')
  if [ "$current" -le "20" ]; then
    icon="⌨ ○○○○○"
  elif [ "$current" -le "40" ]; then
    icon="⌨ ●○○○○"
  elif [ "$current" -le "60" ]; then
    icon="⌨ ●●○○○"
  elif [ "$current" -le "80" ]; then
    icon="⌨ ●●●○○"
  else
    icon="⌨ ●●●●●"
  fi
}

notify_user() {
  notify-send -h int:value:$current -u low "$icon Keyboard" "Brightness: $current%"
}

change_kbd_backlight() {
  brightnessctl -d *::kbd_backlight set "$1" && get_icon && notify_user
}

case "$1" in
--get) get_kbd_backlight ;;
--inc) change_kbd_backlight "+30%" ;;
--dec) change_kbd_backlight "30%-" ;;
*) get_kbd_backlight ;;
esac
