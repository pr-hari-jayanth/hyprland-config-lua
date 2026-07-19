#!/usr/bin/env bash

entries="Shutdown\nReboot\nSuspend\nLock\nLogout"

selected=$(echo -e "$entries" | rofi -dmenu -p "" \
    -theme-str 'window {width: 240px;} listview {lines: 5; spacing: 2px; padding: 4px;} element {padding: 0;} element-text {padding: 10px 16px;} element-icon {size: 0px;}')

case "$selected" in
    "Shutdown") systemctl poweroff ;;
    "Reboot")   systemctl reboot ;;
    "Suspend")  systemctl suspend ;;
    "Lock")     loginctl lock-session ;;
    "Logout")   hyprctl dispatch exit ;;
esac
