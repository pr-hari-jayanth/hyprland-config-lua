#!/bin/bash
DIR_CACHE="$HOME/.cache/current-wallpaper-dir"
WALLPAPER_DIR=$(cat "$DIR_CACHE" 2>/dev/null || echo "$HOME/Pictures/wallpapers")
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.gif' \) | sort)
COUNT=${#WALLS[@]}
if [ $COUNT -eq 0 ]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi
CACHE="$HOME/.cache/current-wallpaper"
CURRENT=$(cat "$CACHE" 2>/dev/null)
IDX=0
for i in "${!WALLS[@]}"; do
    if [ "${WALLS[$i]}" = "$CURRENT" ]; then
        IDX=$(( (i + 1) % COUNT ))
        break
    fi
done
NEXT="${WALLS[$IDX]}"
echo "$NEXT" > "$CACHE"
killall swaybg 2>/dev/null
swaybg -i "$NEXT" -m fill &
notify-send "Wallpaper" "$(basename "$NEXT")"
