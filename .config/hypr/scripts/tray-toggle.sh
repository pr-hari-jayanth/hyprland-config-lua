#!/bin/bash
STATE_FILE="/tmp/waybar-tray-open"

toggle() {
    if grep -q '"custom/tray", "tray"' "$HOME/.config/waybar/config.jsonc"; then
        sed -i '/modules-right/s/"custom\/tray", "tray"/"custom\/tray"/' "$HOME/.config/waybar/config.jsonc"
    else
        sed -i '/modules-right/s/"custom\/tray"/"custom\/tray", "tray"/' "$HOME/.config/waybar/config.jsonc"
    fi
}

if [[ "$1" == "toggle" ]]; then
    toggle
    if [[ -f "$STATE_FILE" ]]; then
        rm "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi
    (sleep 0.3 && waybar) &
    killall -9 waybar
fi

if [[ -f "$STATE_FILE" ]]; then
    echo '{"text":"▼  ","class":"open"}'
else
    echo '{"text":"▶  ","class":"closed"}'
fi
