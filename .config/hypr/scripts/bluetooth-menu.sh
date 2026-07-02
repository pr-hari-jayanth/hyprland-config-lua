#!/bin/bash
# Rofi bluetooth manager

trunc() { echo "$1" | cut -c1-"$2"; }

POWERED=$(bluetoothctl show 2>/dev/null | grep Powered | awk '{print $2}')

if [[ "$POWERED" == "yes" ]]; then
    TOGGLE_ACTION="power off"
    TOGGLE_LABEL="Disable Bluetooth"
    STATUS="On"
    EXTRA="Scan for new devices"
else
    TOGGLE_ACTION="power on"
    TOGGLE_LABEL="Enable Bluetooth"
    STATUS="Off"
    EXTRA=""
fi

declare -A DEV_MAP
DEV_MENU=""
while read -r mac name; do
    [[ -z "$mac" ]] && continue
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    connected=$(echo "$info" | grep Connected | awk '{print $2}')
    icon="󰂲"
    [[ "$connected" == "yes" ]] && icon="󰂯"
    short=$(trunc "$name" 25)
    DEV_MAP["$short"]="$mac"
    DEV_MENU="$DEV_MENU\n$icon  $short"
done < <(bluetoothctl devices)

MENU="$TOGGLE_LABEL"
[[ -n "$EXTRA" ]] && MENU="$MENU\n$EXTRA"
[[ -n "$DEV_MENU" ]] && MENU="$MENU$DEV_MENU"

CHOICE=$(echo -e "$MENU" | rofi -dmenu -p "Bluetooth $STATUS" -theme-str 'listview {columns:1; lines:12;}')
[[ -z "$CHOICE" ]] && exit 0

if [[ "$CHOICE" == "$TOGGLE_LABEL" ]]; then
    bluetoothctl $TOGGLE_ACTION
    exit 0
fi

if [[ "$CHOICE" == "Scan for new devices" ]]; then
    notify-send "Bluetooth" "Scanning..."
    bluetoothctl scan on &
    SCAN_PID=$!
    sleep 8
    kill "$SCAN_PID" 2>/dev/null
    bluetoothctl scan off 2>/dev/null

    declare -A FOUND_MAP
    FOUND_MENU=""
    while read -r mac name; do
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        paired=$(echo "$info" | grep Paired | awk '{print $2}')
        [[ "$paired" == "yes" ]] && continue
        short=$(trunc "$name" 25)
        FOUND_MAP["$short"]="$mac"
        FOUND_MENU="$FOUND_MENU\n  $short"
    done < <(bluetoothctl devices)

    if [[ -z "$FOUND_MENU" ]]; then
        notify-send "Bluetooth" "No new devices found"
        exit 0
    fi

    TARGET=$(echo -e "Cancel$FOUND_MENU" | rofi -dmenu -p "Select device to pair" -theme-str 'listview {columns:1; lines:8;}')
    [[ -z "$TARGET" || "$TARGET" == "Cancel" ]] && exit 0

    SHORT=$(echo "$TARGET" | sed 's/^[^ ]*  //')
    MAC="${FOUND_MAP[$SHORT]}"
    if [[ -n "$MAC" ]]; then
        bluetoothctl pair "$MAC"
        sleep 1
        bluetoothctl trust "$MAC"
        bluetoothctl connect "$MAC"
        notify-send "Bluetooth" "Paired & connected to $SHORT"
    fi
    exit 0
fi

SHORT=$(echo "$CHOICE" | sed 's/^[^ ]*  //')
MAC="${DEV_MAP[$SHORT]}"
[[ -z "$MAC" ]] && exit 0

INFO=$(bluetoothctl info "$MAC" 2>/dev/null)
CONNECTED=$(echo "$INFO" | grep Connected | awk '{print $2}')
PAIRED=$(echo "$INFO" | grep Paired | awk '{print $2}')

if [[ "$CONNECTED" == "yes" ]]; then
    ACTION="disconnect"
    ACTION_LABEL="Disconnect"
elif [[ "$PAIRED" == "yes" ]]; then
    ACTION="connect"
    ACTION_LABEL="Connect"
else
    ACTION="pair"
    ACTION_LABEL="Pair"
fi

CONFIRM=$(echo -e "$ACTION_LABEL\nRemove Device\nCancel" | rofi -dmenu -p "$SHORT" -theme-str 'listview {columns:1; lines:3;}')
case "$CONFIRM" in
    "$ACTION_LABEL")
        bluetoothctl $ACTION "$MAC"
        notify-send "Bluetooth" "$ACTION_LABEL $SHORT"
        ;;
    "Remove Device")
        bluetoothctl remove "$MAC"
        notify-send "Bluetooth" "Removed $SHORT"
        ;;
esac
