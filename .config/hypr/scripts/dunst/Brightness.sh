#!/bin/bash

BRIGHTNESS_NOTIF_ID=9993
step=5

get_backlight() {
  brightnessctl -m | cut -d, -f4 | sed 's/%//'
}

get_icon() {
  local current_val=$1
  if [ "$current_val" -le "20" ]; then
    echo "○○○○○"
  elif [ "$current_val" -le "40" ]; then
    echo "●○○○○"
  elif [ "$current_val" -le "60" ]; then
    echo "●●○○○"
  elif [ "$current_val" -le "80" ]; then
    echo "●●●○○"
  else
    echo "●●●●●"
  fi
}

notify_user() {
  local brightness=$1
  local icon=$(get_icon $brightness)
  dunstify -r $BRIGHTNESS_NOTIF_ID -h int:value:$brightness -u low "$icon Screen" "Brightness: ${brightness}%"
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
  notify_user $new_brightness
}

case "$1" in
--get) get_backlight ;;
--inc) change_backlight "+${step}%" ;;
--dec) change_backlight "${step}%-" ;;
*) get_backlight ;;
esac
