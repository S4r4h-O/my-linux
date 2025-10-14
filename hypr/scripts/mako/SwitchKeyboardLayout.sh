#!/bin/bash
layout_file="$HOME/.cache/kb_layout"
settings_file="$HOME/.config/hypr/UserConfigs/UserSettings.conf"

ignore_patterns=(
  "--(avrcp)"
  "Bluetooth Speaker"
  "Other Device Name"
)

if [ ! -f "$layout_file" ]; then
  default_layout=$(grep 'kb_layout = ' "$settings_file" | cut -d '=' -f 2 | tr -d '[:space:]' | cut -d ',' -f 1 2>/dev/null)
  default_layout=${default_layout:-"us"}
  echo "$default_layout" >"$layout_file"
fi

current_layout=$(cat "$layout_file")

if [ -f "$settings_file" ]; then
  kb_layout_line=$(grep 'kb_layout = ' "$settings_file" | cut -d '=' -f 2)
  kb_layout_line=$(echo "$kb_layout_line" | tr -d '[:space:]')
  IFS=',' read -r -a layout_mapping <<<"$kb_layout_line"
else
  notify-send -u critical "⌨️ Keyboard Layout" "Settings file not found"
  exit 1
fi

layout_count=${#layout_mapping[@]}

for ((i = 0; i < layout_count; i++)); do
  if [ "$current_layout" == "${layout_mapping[i]}" ]; then
    current_index=$i
    break
  fi
done

next_index=$(((current_index + 1) % layout_count))
new_layout="${layout_mapping[next_index]}"

get_keyboard_names() {
  hyprctl devices -j | jq -r '.keyboards[].name'
}

is_ignored() {
  local device_name=$1
  for pattern in "${ignore_patterns[@]}"; do
    [[ "$device_name" == *"$pattern"* ]] && return 0
  done
  return 1
}

change_layout() {
  local error_found=false
  while read -r name; do
    is_ignored "$name" && continue
    hyprctl switchxkblayout "$name" "$next_index"
    [ $? -ne 0 ] && error_found=true
  done <<<"$(get_keyboard_names)"
  $error_found && return 1
  return 0
}

if ! change_layout; then
  notify-send -u low -t 2000 "❌ Keyboard Layout" "Layout change failed"
  exit 1
else
  notify-send -u low "⌨️ Keyboard Layout" "$new_layout"
fi

echo "$new_layout" >"$layout_file"
