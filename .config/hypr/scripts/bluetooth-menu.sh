#!/bin/bash
# Rofi bluetooth manager

notify() { notify-send "Bluetooth" "$1"; }

get_powered() {
    bluetoothctl show 2>/dev/null | grep Powered | awk '{print $2}'
}

get_connected() {
    local mac="$1"
    bluetoothctl info "$mac" 2>/dev/null | grep Connected | awk '{print $2}'
}

get_paired() {
    local mac="$1"
    bluetoothctl info "$mac" 2>/dev/null | grep Paired | awk '{print $2}'
}

lookup_index() {
    local needle="$1"; shift
    local i=0
    for item; do
        [[ "$item" == "$needle" ]] && echo "$i" && return
        ((i++))
    done
    echo -1
}

main_menu() {
    local powered
    powered=$(get_powered)
    local toggle
    if [[ "$powered" == "yes" ]]; then
        toggle="  Turn Bluetooth Off"
    else
        toggle="  Turn Bluetooth On"
    fi

    local labels=() macs=()
    while read -r mac name; do
        [[ -z "$mac" ]] && continue
        local connected
        connected=$(get_connected "$mac")
        local icon=""
        [[ "$connected" == "yes" ]] && icon=""
        labels+=("$icon  $name")
        macs+=("$mac")
    done < <(bluetoothctl devices)

    local menu="$toggle"
    for ((i=0; i<${#labels[@]}; i++)); do
        menu="$menu\n${labels[$i]}"
    done
    menu="$menu\n  Add Device"

    local choice
    choice=$(echo -e "$menu" | rofi -dmenu -p "Bluetooth" -theme-str 'listview {columns:1; lines:14;}')
    [[ -z "$choice" ]] && exit 0

    if [[ "$choice" == *"Turn Bluetooth"* ]]; then
        if [[ "$powered" == "yes" ]]; then
            bluetoothctl power off && notify "Bluetooth off"
        else
            bluetoothctl power on && notify "Bluetooth on"
        fi
        exit 0
    fi

    if [[ "$choice" == *"Add Device"* ]]; then
        add_device
        exit 0
    fi

    local idx
    idx=$(lookup_index "$choice" "${labels[@]}")
    [[ "$idx" -lt 0 ]] && exit 0
    device_actions "${macs[$idx]}" "$(echo "${labels[$idx]}" | sed 's/^[^ ]*  //')"
}

device_actions() {
    local mac="$1" name="$2"
    local connected
    connected=$(get_connected "$mac")
    local actions
    if [[ "$connected" == "yes" ]]; then
        actions="睊  Disconnect\n  Remove Device\nCancel"
    else
        actions="  Connect\n  Remove Device\nCancel"
    fi

    local action
    action=$(echo -e "$actions" | rofi -dmenu -p "$name" -theme-str 'listview {columns:1; lines:3;}')
    [[ -z "$action" || "$action" == "Cancel" ]] && exit 0

    case "$action" in
        *"Disconnect"*)
            bluetoothctl disconnect "$mac" && notify "Disconnected $name" ;;
        *"Connect"*)
            bluetoothctl connect "$mac" && notify "Connected $name" ;;
        *"Remove"*)
            local confirm
            confirm=$(echo -e "  Yes, Remove\nCancel" | rofi -dmenu -p "Remove $name?" -theme-str 'listview {columns:1; lines:2;}')
            if [[ "$confirm" == *"Remove"* ]]; then
                bluetoothctl remove "$mac" && notify "Removed $name"
            fi
            ;;
    esac
}

add_device() {
    local powered
    powered=$(get_powered)
    if [[ "$powered" != "yes" ]]; then
        notify "Turn Bluetooth on first"
        exit 0
    fi

    notify "Scanning..."
    bluetoothctl scan on &
    local scan_pid=$!
    sleep 10
    kill "$scan_pid" 2>/dev/null
    bluetoothctl scan off 2>/dev/null

    # Collect already-paired MACs for filtering
    local paired_macs=""
    while read -r mac _; do
        paired_macs="$paired_macs $mac"
    done < <(bluetoothctl paired-devices)

    local labels=() macs=()
    while read -r mac name; do
        [[ -z "$mac" ]] && continue
        # Skip already paired
        [[ "$paired_macs" == *"$mac"* ]] && continue
        labels+=("  $name")
        macs+=("$mac")
    done < <(bluetoothctl devices)

    if [[ ${#labels[@]} -eq 0 ]]; then
        notify "No new devices found"
        exit 0
    fi

    local menu=""
    for ((i=0; i<${#labels[@]}; i++)); do
        menu="$menu\n${labels[$i]}"
    done

    local choice
    choice=$(echo -e "$menu" | rofi -dmenu -p "Select device" -theme-str 'listview {columns:1; lines:10;}')
    [[ -z "$choice" ]] && exit 0

    local idx
    idx=$(lookup_index "$choice" "${labels[@]}")
    [[ "$idx" -lt 0 ]] && exit 0

    local mac="${macs[$idx]}"
    local name
    name=$(echo "${labels[$idx]}" | sed 's/^[^ ]*  //')

    notify "Pairing with $name..."
    bluetoothctl pair "$mac"
    sleep 1
    bluetoothctl trust "$mac"
    bluetoothctl connect "$mac" && notify "Connected to $name" || notify "Pairing complete for $name"
}

main_menu
