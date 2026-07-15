#!/bin/bash
# Theme switcher: Nord / Catppuccin Mocha / Retro Minimalism

CACHE_FILE="/tmp/current-theme"
C="${HOME}/.config"

# ── Color Palettes ──────────────────────────────────────────

declare -A NORD=(
    [bg]="#2e3440" [surface]="#3b4252" [surface2]="#434c5e" [muted]="#4c566a"
    [fg]="#d8dee9" [fg2]="#e5e9f0" [fg3]="#eceff4"
    [teal]="#8fbcbb" [cyan]="#88c0d0" [blue]="#81a1c1" [dark_blue]="#5e81ac"
    [red]="#bf616a" [orange]="#d08770" [yellow]="#ebcb8b" [green]="#a3be8c" [purple]="#b48ead"
)

declare -A CTP=(
    [bg]="#1e1e2e" [surface]="#313244" [surface2]="#45475a" [muted]="#585b70"
    [fg]="#cdd6f4" [fg2]="#bac2de" [fg3]="#a6adc8"
    [teal]="#94e2d5" [cyan]="#89dceb" [blue]="#89b4fa" [dark_blue]="#74c7ec"
    [red]="#f38ba8" [orange]="#fab387" [yellow]="#f9e2af" [green]="#a6e3a1" [purple]="#cba6f7"
)

declare -A RETRO=(
    [bg]="#161616" [surface]="#000000" [surface2]="#222222" [muted]="#404040"
    [fg]="#d8d8d8" [fg2]="#9b9b9b" [fg3]="#efefef"
    [teal]="#207874" [cyan]="#3aad9e" [blue]="#4477cc" [dark_blue]="#335599"
    [red]="#e04444" [orange]="#ff723e" [yellow]="#d4aa44" [green]="#44aa66" [purple]="#8866bb"
)

# Build mapping: each theme has a nord->theme mapping
build_map() {
    local -n t="$1"
    for key in "${!NORD[@]}"; do
        echo "${NORD[$key]}:${t[$key]}"
    done
}

get_palette() {
    case "$1" in nord) echo "NORD" ;; catppuccin) echo "CTP" ;; retro) echo "RETRO" ;; esac
}

apply_theme() {
    local file="$1" from="$2" to="$3"
    [[ ! -f "$file" ]] && return
    local from_arr=$(get_palette "$from")
    local to_arr=$(get_palette "$to")
    local -n f="$from_arr" t="$to_arr"
    for key in "${!f[@]}"; do
        sed -i "s/${f[$key]}/${t[$key]}/gi" "$file"
    done
}

# ── Main ────────────────────────────────────────────────────

THEMES="nord\ncatppuccin\nretro"

if [[ "$1" == "menu" ]]; then
    CURRENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "nord")
    THEME=$(printf "$THEMES" | rofi -dmenu -p "Theme" -mesg "Current: ${CURRENT}" -select "$CURRENT")
    [[ -z "$THEME" ]] && exit 0
elif [[ "$1" == "nord" || "$1" == "catppuccin" || "$1" == "retro" ]]; then
    THEME="$1"
else
    CURRENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "nord")
    if [[ "$1" == "toggle" ]]; then
        case "$CURRENT" in
            nord) THEME="catppuccin" ;;
            catppuccin) THEME="retro" ;;
            retro) THEME="nord" ;;
        esac
    else
        echo "$CURRENT"
        exit 0
    fi
fi
# Read previous theme before overwriting cache
PREV=$(cat "$CACHE_FILE" 2>/dev/null || echo "nord")
echo "$THEME" > "$CACHE_FILE"

if [[ "$PREV" != "$THEME" ]]; then
    # Restore to nord first, then apply new theme
    if [[ "$PREV" != "nord" ]]; then
        for dir in "waybar/style.css" "rofi/themes/nordic.rasi" "kitty/kitty.conf" "dunst/dunstrc"; do
            apply_theme "${C}/${dir}" "$PREV" "nord"
        done
    fi

    # Backup nordic.lua before overwriting
    if [[ "$THEME" != "nord" ]]; then
        cp "${C}/hypr/nordic.lua" "${C}/hypr/nordic.lua.bak" 2>/dev/null || true
    fi

    # Swap hyprland color palette (nordic.lua always gets the active theme)
    if [[ "$THEME" == "nord" ]]; then
        cp "${C}/hypr/nordic.lua.bak" "${C}/hypr/nordic.lua" 2>/dev/null || true
    else
        cp "${C}/hypr/${THEME}.lua" "${C}/hypr/nordic.lua"
    fi

    # Apply new theme colors
    if [[ "$THEME" != "nord" ]]; then
        for dir in "waybar/style.css" "rofi/themes/nordic.rasi" "kitty/kitty.conf" "dunst/dunstrc"; do
            apply_theme "${C}/${dir}" "nord" "$THEME"
        done
    fi
fi

# ── Wallpaper directory ────────────────────────────────────

WALL_DIR_NORD="$HOME/Pictures/wallpapers"
WALL_DIR_CTP="$HOME/Pictures/wallpapers-catppuccin"
WALL_DIR_RETRO="$HOME/Pictures/wallpapers-retro"

case "$THEME" in
    catppuccin) WDIR="$WALL_DIR_CTP" ;;
    retro)      WDIR="$WALL_DIR_RETRO" ;;
    *)          WDIR="$WALL_DIR_NORD" ;;
esac
echo "$WDIR" > "$HOME/.cache/current-wallpaper-dir"

mapfile -t WALLS < <(find "$WDIR" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.gif' \) 2>/dev/null | sort)
if [[ ${#WALLS[@]} -gt 0 ]]; then
    WALL="${WALLS[$RANDOM % ${#WALLS[@]}]}"
    echo "$WALL" > "$HOME/.cache/current-wallpaper"
fi

# ── GTK theme ───────────────────────────────────────────────

case "$THEME" in
    catppuccin) GTK_THEME="Catppuccin-Mocha" ;;
    retro)      GTK_THEME="ClassicPlatinumStreamlined" ;;
    *)          GTK_THEME="Nordic" ;;
esac

sed -i "s/gtk-theme-name=.*/gtk-theme-name=${GTK_THEME}/" "${C}/gtk-3.0/settings.ini"
sed -i "s/gtk-theme-name=.*/gtk-theme-name=${GTK_THEME}/" "${C}/gtk-4.0/settings.ini" 2>/dev/null || true
sed -i "s/Net\/ThemeName \".*\"/Net\/ThemeName \"${GTK_THEME}\"/" "${C}/xsettingsd/xsettingsd.conf"
killall xsettingsd 2>/dev/null || true
${HOME}/.local/bin/xsettingsd &>/dev/null &
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true

# ── Brave theme ────────────────────────────────────────────

"${C}/hypr/scripts/brave-theme.sh" "$THEME" 2>/dev/null || true

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
