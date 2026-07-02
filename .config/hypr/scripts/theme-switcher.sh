#!/bin/bash
# Theme switcher: Nord <-> Catppuccin Mocha

CACHE_FILE="/tmp/current-theme"
C="${HOME}/.config"

# Color mappings Nord -> Catppuccin (full hex, longer first to avoid partial matches)
declare -A MAP=(
    ["#e5e9f0"]="#bac2de"  ["#eceff4"]="#a6adc8"  ["#88c0d0"]="#89dceb"
    ["#8fbcbb"]="#94e2d5"  ["#81a1c1"]="#89b4fa"  ["#5e81ac"]="#74c7ec"
    ["#bf616a"]="#f38ba8"  ["#d08770"]="#fab387"  ["#ebcb8b"]="#f9e2af"
    ["#a3be8c"]="#a6e3a1"  ["#b48ead"]="#cba6f7"  ["#d8dee9"]="#cdd6f4"
    ["#2e3440"]="#1e1e2e"  ["#3b4252"]="#313244"  ["#434c5e"]="#45475a"
    ["#4c566a"]="#585b70"
)

apply_theme() {
    local file="$1" dir="$2"
    [[ ! -f "$file" ]] && return
    if [[ "$dir" == "catppuccin" ]]; then
        for k in "${!MAP[@]}"; do sed -i "s/$k/${MAP[$k]}/gi" "$file"; done
    else
        for k in "${!MAP[@]}"; do sed -i "s/${MAP[$k]}/$k/gi" "$file"; done
    fi
}

# ── Main ────────────────────────────────────────────────────

if [[ "$1" == "menu" ]]; then
    CURRENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "nord")
    THEME=$(printf "nord\ncatppuccin" | rofi -dmenu -p "Theme" -mesg "Current: ${CURRENT}" -select "$CURRENT")
    [[ -z "$THEME" ]] && exit 0
elif [[ "$1" != "nord" && "$1" != "catppuccin" ]]; then
    CURRENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "nord")
    if [[ "$1" == "toggle" ]]; then
        THEME="nord"
        [[ "$CURRENT" == "nord" ]] && THEME="catppuccin"
    else
        echo "$CURRENT"
        exit 0
    fi
else
    THEME="$1"
fi
echo "$THEME" > "$CACHE_FILE"

# Swap hyprland color palette (nordic.lua always gets the active theme)
if [[ "$THEME" == "catppuccin" ]]; then
    cp "${C}/hypr/nordic.lua" "${C}/hypr/nordic.lua.bak" 2>/dev/null
    cp "${C}/hypr/catppuccin.lua" "${C}/hypr/nordic.lua"
else
    cp "${C}/hypr/nordic.lua.bak" "${C}/hypr/nordic.lua" 2>/dev/null || true
fi

# Apply to all config files that use #hex colors
for dir in "waybar/style.css" "rofi/nordic.rasi" "kitty/kitty.conf" "dunst/dunstrc"; do
    apply_theme "${C}/${dir}" "$THEME"
done

# ── Wallpaper directory ────────────────────────────────────

WALL_DIR_NORD="$HOME/Pictures/wallpapers"
WALL_DIR_CTP="$HOME/Pictures/wallpapers-catppuccin"

if [[ "$THEME" == "catppuccin" ]]; then
    WDIR="$WALL_DIR_CTP"
else
    WDIR="$WALL_DIR_NORD"
fi
echo "$WDIR" > "$HOME/.cache/current-wallpaper-dir"

# Pick a random wallpaper from the new directory
mapfile -t WALLS < <(find "$WDIR" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.gif' \) | sort)
if [[ ${#WALLS[@]} -gt 0 ]]; then
    WALL="${WALLS[$RANDOM % ${#WALLS[@]}]}"
    echo "$WALL" > "$HOME/.cache/current-wallpaper"
fi

# ── GTK theme ───────────────────────────────────────────────

GTK_NORD="Nordic"
GTK_CTP="Catppuccin-Mocha"

if [[ "$THEME" == "catppuccin" ]]; then
    GTK_THEME="$GTK_CTP"
else
    GTK_THEME="$GTK_NORD"
fi

# settings.ini (gtk-3.0)
sed -i "s/gtk-theme-name=.*/gtk-theme-name=${GTK_THEME}/" "${C}/gtk-3.0/settings.ini"
# settings.ini (gtk-4.0)
sed -i "s/gtk-theme-name=.*/gtk-theme-name=${GTK_THEME}/" "${C}/gtk-4.0/settings.ini" 2>/dev/null || true
# xsettingsd
sed -i "s/Net\/ThemeName \".*\"/Net\/ThemeName \"${GTK_THEME}\"/" "${C}/xsettingsd/xsettingsd.conf"
killall xsettingsd 2>/dev/null || true
xsettingsd &>/dev/null &
# gsettings (immediate effect for some apps)
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true

# ── Reload everything ──────────────────────────────────────

killall -9 waybar 2>/dev/null
killall -SIGUSR1 dunst 2>/dev/null
WALL=$(cat "${HOME}/.cache/current-wallpaper" 2>/dev/null)
if [[ -n "$WALL" && -f "$WALL" ]]; then
    killall swaybg 2>/dev/null
    swaybg -i "$WALL" -m fill &>/dev/null &
fi
waybar &>/dev/null &
hyprctl reload 2>/dev/null

notify-send "Theme" "Switched to ${THEME^}"
