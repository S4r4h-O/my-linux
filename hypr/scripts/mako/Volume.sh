#!/bin/bash
sDIR="$HOME/.config/hypr/scripts"

get_volume() {
  volume=$(pamixer --get-volume)
  [[ "$volume" -eq "0" ]] && echo "Muted" || echo "$volume %"
}

get_icon() {
  current=$(get_volume)
  if [[ "$current" == "Muted" ]]; then
    echo "🔇"
  elif [[ "${current%\%}" -le 30 ]]; then
    echo "🔈"
  elif [[ "${current%\%}" -le 60 ]]; then
    echo "🔉"
  else
    echo "🔊"
  fi
}

notify_user() {
  icon=$(get_icon)
  if [[ "$(get_volume)" == "Muted" ]]; then
    notify-send -u low "$icon Volume" "Muted"
  else
    notify-send -h int:value:"$(get_volume | sed 's/%//')" -u low "$icon Volume" "$(get_volume)"
    "$sDIR/Sounds.sh" --volume
  fi
}

inc_volume() {
  [ "$(pamixer --get-mute)" == "true" ] && toggle_mute || pamixer -i 5 --allow-boost --set-limit 150 && notify_user
}

dec_volume() {
  [ "$(pamixer --get-mute)" == "true" ] && toggle_mute || pamixer -d 5 && notify_user
}

toggle_mute() {
  if [ "$(pamixer --get-mute)" == "false" ]; then
    pamixer -m && notify-send -u low "🔇 Volume" "Muted"
  else
    pamixer -u && notify-send -u low "$(get_icon) Volume" "Unmuted"
  fi
}

toggle_mic() {
  if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
    pamixer --default-source -m && notify-send -u low "🎤❌ Microphone" "OFF"
  else
    pamixer -u --default-source u && notify-send -u low "🎤 Microphone" "ON"
  fi
}

get_mic_icon() {
  current=$(pamixer --default-source --get-volume)
  [[ "$current" -eq "0" ]] && echo "🎤❌" || echo "🎤"
}

get_mic_volume() {
  volume=$(pamixer --default-source --get-volume)
  [[ "$volume" -eq "0" ]] && echo "Muted" || echo "$volume %"
}

notify_mic_user() {
  volume=$(get_mic_volume)
  icon=$(get_mic_icon)
  notify-send -h int:value:"${volume%\%}" -u low "$icon Microphone" "$volume"
}

inc_mic_volume() {
  [ "$(pamixer --default-source --get-mute)" == "true" ] && toggle_mic || pamixer --default-source -i 5 && notify_mic_user
}

dec_mic_volume() {
  [ "$(pamixer --default-source --get-mute)" == "true" ] && toggle_mic || pamixer --default-source -d 5 && notify_mic_user
}

case "$1" in
--get) get_volume ;;
--inc) inc_volume ;;
--dec) dec_volume ;;
--toggle) toggle_mute ;;
--toggle-mic) toggle_mic ;;
--get-icon) get_icon ;;
--get-mic-icon) get_mic_icon ;;
--mic-inc) inc_mic_volume ;;
--mic-dec) dec_mic_volume ;;
*) get_volume ;;
esac
