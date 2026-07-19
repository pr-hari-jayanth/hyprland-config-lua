#!/usr/bin/env bash

entries="Shutdown\nReboot\nSuspend\nLock\nLogout"

selected=$(echo -e "$entries" | rofi -dmenu -p "" \
    -theme-str 'window {width: 200px; location: center; anchor: center;} inputbar {spacing: 0; padding: 6px 0; children: [textbox-search, entry];} listview {lines: 5; spacing: 0; padding: 0; columns: 1;} element {padding: 0; orientation: vertical;} element-text {padding: 10px 0; horizontal-align: 0.5;} element-icon {size: 0px;} textbox {horizontal-align: 0.5;} entry {horizontal-align: 0.5;} textbox-search {horizontal-align: 0.5;}')

case "$selected" in
    "Shutdown") systemctl poweroff ;;
    "Reboot")   systemctl reboot ;;
    "Suspend")  systemctl suspend ;;
    "Lock")     loginctl lock-session ;;
    "Logout")   hyprctl dispatch exit ;;
esac
