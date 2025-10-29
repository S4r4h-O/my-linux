#!/bin/bash
# Airplane Mode toggle

wifi_blocked=$(rfkill list wifi | grep -o "Soft blocked: yes")

if [ -n "$wifi_blocked" ]; then
  rfkill unblock wifi
  notify-send -u low "✈ Airplane Mode" "OFF"
else
  rfkill block wifi
  notify-send -u low "✈ Airplane Mode" "ON"
fi
