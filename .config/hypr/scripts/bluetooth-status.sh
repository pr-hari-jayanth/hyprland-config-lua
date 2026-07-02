#!/bin/bash
trunc() { echo "$1" | cut -c1-15; }
POWERED=$(bluetoothctl show 2>/dev/null | grep Powered | awk '{print $2}')
if [[ "$POWERED" == "yes" ]]; then
    CONNECTED=$(bluetoothctl devices Connected 2>/dev/null | awk '{$1=""; $2=""; sub(/^  /,""); print}' | while read -r line; do trunc "$line"; done | tr '\n' ',' | sed 's/,$//')
    if [[ -n "$CONNECTED" ]]; then
        echo " $CONNECTED"
    else
        echo "󰂯"
    fi
else
    echo "󰂲"
fi
