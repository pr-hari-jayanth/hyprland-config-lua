#!/bin/bash
FLAG="/tmp/hyprsunset-active"
if [ -f "$FLAG" ]; then
    hyprctl hyprsunset identity
    rm "$FLAG"
    notify-send "Night Light" "Disabled"
else
    hyprctl hyprsunset temperature 4500
    touch "$FLAG"
    notify-send "Night Light" "Enabled (4500K)"
fi
