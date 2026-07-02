#!/usr/bin/env bash

entries="Shutdown\nReboot\nSuspend\nLock\nLogout"

selected=$(echo -e "$entries" | rofi -dmenu -p "Power" -theme-str 'window {width: 200px;} listview {lines: 5;}')

case "$selected" in
    "Shutdown") systemctl poweroff ;;
    "Reboot")   systemctl reboot ;;
    "Suspend")  systemctl suspend ;;
    "Lock")     loginctl lock-session ;;
    "Logout")   hyprctl dispatch exit ;;
esac
