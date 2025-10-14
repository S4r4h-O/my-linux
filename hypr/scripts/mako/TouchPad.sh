#!/bin/bash
export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

enable_touchpad() {
  printf "true" >"$STATUS_FILE"
  notify-send -u low "Touchpad" "Enabled"
  hyprctl keyword '$TOUCHPAD_ENABLED' "true" -r
}

disable_touchpad() {
  printf "false" >"$STATUS_FILE"
  notify-send -u low "Touchpad" "Disabled"
  hyprctl keyword '$TOUCHPAD_ENABLED' "false" -r
}

if ! [ -f "$STATUS_FILE" ]; then
  enable_touchpad
else
  [ $(cat "$STATUS_FILE") = "true" ] && disable_touchpad || enable_touchpad
fi
