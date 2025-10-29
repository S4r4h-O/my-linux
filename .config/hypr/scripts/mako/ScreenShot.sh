#!/bin/bash
# Screenshots com mako
time=$(date "+%d-%b_%H-%M-%S")
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"
sDIR="$HOME/.config/hypr/scripts"

active_window_class=$(hyprctl -j activewindow | jq -r '(.class)')
active_window_file="Screenshot_${time}_${active_window_class}.png"
active_window_path="${dir}/${active_window_file}"

notify_view() {
  if [[ "$1" == "active" ]]; then
    if [[ -e "${active_window_path}" ]]; then
      "${sDIR}/Sounds.sh" --screenshot
      notify-send -t 10000 "Screenshot" "${active_window_class} saved"
    else
      notify-send -u low "Screenshot" "${active_window_class} not saved"
      "${sDIR}/Sounds.sh" --error
    fi
  elif [[ "$1" == "swappy" ]]; then
    "${sDIR}/Sounds.sh" --screenshot
    notify-send -t 10000 "Screenshot" "Captured by Swappy"
  else
    local check_file="${dir}/${file}"
    if [[ -e "$check_file" ]]; then
      "${sDIR}/Sounds.sh" --screenshot
      notify-send -t 10000 "📸 Screenshot" "Saved"
    else
      notify-send -u low "Screenshot" "Not saved"
      "${sDIR}/Sounds.sh" --error
    fi
  fi
}

countdown() {
  for sec in $(seq $1 -1 1); do
    notify-send -t 1000 "Taking shot" "in $sec secs"
    sleep 1
  done
}

shotnow() {
  cd ${dir} && grim - | tee "$file" | wl-copy
  sleep 2
  notify_view
}

shot5() {
  countdown '5'
  sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
  sleep 1
  notify_view
}

shot10() {
  countdown '10'
  sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
  notify_view
}

shotwin() {
  w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
  w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
  cd ${dir} && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
  notify_view
}

shotarea() {
  tmpfile=$(mktemp)
  grim -g "$(slurp)" - >"$tmpfile"
  if [[ -s "$tmpfile" ]]; then
    wl-copy <"$tmpfile"
    mv "$tmpfile" "$dir/$file"
  fi
  notify_view
}

shotactive() {
  active_window_class=$(hyprctl -j activewindow | jq -r '(.class)')
  active_window_file="Screenshot_${time}_${active_window_class}.png"
  active_window_path="${dir}/${active_window_file}"
  hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - "${active_window_path}"
  sleep 1
  notify_view "active"
}

shotswappy() {
  tmpfile=$(mktemp)
  grim -g "$(slurp)" - >"$tmpfile"
  if [[ -s "$tmpfile" ]]; then
    wl-copy <"$tmpfile"
    notify_view "swappy"
  fi
}

[[ ! -d "$dir" ]] && mkdir -p "$dir"

case "$1" in
--now) shotnow ;;
--in5) shot5 ;;
--in10) shot10 ;;
--win) shotwin ;;
--area) shotarea ;;
--active) shotactive ;;
--swappy) shotswappy ;;
*) echo "Available Options : --now --in5 --in10 --win --area --active --swappy" ;;
esac
