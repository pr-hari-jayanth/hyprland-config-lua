#!/bin/bash
STATUS=$(mpc status 2>/dev/null) || { echo '{"text":""}'; exit 0; }

STATE=$(mpc status 2>/dev/null | grep -oP '^.*\[(\w+)\]' | grep -oP '\[\K\w+')
TITLE=$(mpc current 2>/dev/null)

if [[ "$STATE" == "playing" || "$STATE" == "paused" ]]; then
    ICON=""
    CLASS="playing"
    [[ "$STATE" == "paused" ]] && { ICON=""; CLASS="paused"; }
    TEXT="$ICON $TITLE"
    if [[ ${#TEXT} -gt 32 ]]; then
        TEXT=$(echo "$TEXT" | grep -o '^.\{0,29\}')"..."
    fi
    TEXT=$(echo "$TEXT" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')
    echo "{\"text\":\"$TEXT\",\"class\":\"$CLASS\"}"
else
    echo '{"text":""}'
fi
