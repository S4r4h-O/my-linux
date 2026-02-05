#!/bin/bash

VOLUME_NOTIF_ID=9991
MIC_NOTIF_ID=9992

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
  volume=$(pamixer --get-volume)
  if [[ "$(get_volume)" == "Muted" ]]; then
    dunstify -r $VOLUME_NOTIF_ID -a "volume-control" -u low "$icon Volume" "Muted"
  else
    dunstify -r $VOLUME_NOTIF_ID -a "volume-control" -h int:value:"$volume" -u low "$icon Volume" "$(get_volume)"
  fi
}

inc_volume() {
  if [ "$(pamixer --get-mute)" == "true" ]; then
    toggle_mute
  else
    pamixer -i 5 --allow-boost --set-limit 150 && notify_user
  fi
}

dec_volume() {
  if [ "$(pamixer --get-mute)" == "true" ]; then
    toggle_mute
  else
    pamixer -d 5 && notify_user
  fi
}

toggle_mute() {
  if [ "$(pamixer --get-mute)" == "false" ]; then
    pamixer -m && dunstify -r $VOLUME_NOTIF_ID -a "volume-control" -u low "🔇 Volume" "Muted"
  else
    pamixer -u && dunstify -r $VOLUME_NOTIF_ID -a "volume-control" -u low "$(get_icon) Volume" "Unmuted"
  fi
}

toggle_mic() {
  if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
    pamixer --default-source -m && dunstify -r $MIC_NOTIF_ID -a "mic-control" -u low "🎤❌ Microphone" "OFF"
  else
    pamixer --default-source -u && dunstify -r $MIC_NOTIF_ID -a "mic-control" -u low "🎤 Microphone" "ON"
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
  volume=$(pamixer --default-source --get-volume)
  icon=$(get_mic_icon)
  dunstify -r $MIC_NOTIF_ID -a "mic-control" -h int:value:"$volume" -u low "$icon Microphone" "$(get_mic_volume)"
}

inc_mic_volume() {
  if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
    toggle_mic
  else
    pamixer --default-source -i 5 && notify_mic_user
  fi
}

dec_mic_volume() {
  if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
    toggle_mic
  else
    pamixer --default-source -d 5 && notify_mic_user
  fi
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
