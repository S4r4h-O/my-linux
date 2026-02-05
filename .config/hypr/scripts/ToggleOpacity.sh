#!/bin/bash
ADDR=$(hyprctl activewindow -j | jq -r '.address')
CURRENT=$(hyprctl clients -j | jq -r --arg addr "$ADDR" '.[] | select(.address == $addr) | .opacity')

if (($(echo "$CURRENT < 1.0" | bc -l))); then
  hyprctl setprop $ADDR opacity 1.0
else
  hyprctl setprop $ADDR opacity 0.75
fi
