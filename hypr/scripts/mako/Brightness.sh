#!/bin/bash
step=10

get_backlight() {
  brightnessctl -m | cut -d, -f4 | sed 's/%//'
}

get_icon() {
  current=$(get_backlight)
  if [ "$current" -le "20" ]; then
    icon="○○○○○"
  elif [ "$current" -le "40" ]; then
    icon="●○○○○"
  elif [ "$current" -le "60" ]; then
    icon="●●○○○"
  elif [ "$current" -le "80" ]; then
    icon="●●●○○"
  else
    icon="●●●●●"
  fi
}

notify_user() {
  notify-send -h int:value:$current -u low "$icon Screen" "Brightness: $current%"
}

change_backlight() {
  local current_brightness=$(get_backlight)
  local new_brightness

  if [[ "$1" == "+${step}%" ]]; then
    new_brightness=$((current_brightness + step))
  elif [[ "$1" == "${step}%-" ]]; then
    new_brightness=$((current_brightness - step))
  fi

  ((new_brightness < 5)) && new_brightness=5
  ((new_brightness > 100)) && new_brightness=100

  brightnessctl set "${new_brightness}%"
  get_icon
  current=$new_brightness
  notify_user
}

case "$1" in
--get) get_backlight ;;
--inc) change_backlight "+${step}%" ;;
--dec) change_backlight "${step}%-" ;;
*) get_backlight ;;
esac
