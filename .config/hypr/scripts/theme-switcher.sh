#!/bin/bash
# Theme switcher: Nord / Catppuccin Mocha / Gruvbox Dark / Black Boxxy

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

declare -A GRUV=(
    [bg]="#1d2021" [surface]="#282828" [surface2]="#32302f" [muted]="#504945"
    [fg]="#ebdbb2" [fg2]="#d5c4a1" [fg3]="#fbf1c7"
    [teal]="#689d6a" [cyan]="#8ec07c" [blue]="#458588" [dark_blue]="#83a598"
    [red]="#cc241d" [orange]="#d65d0e" [yellow]="#d79921" [green]="#98971a" [purple]="#b16286"
)

declare -A BLACK=(
    [bg]="#000000" [surface]="#0d0d0d" [surface2]="#1a1a1a" [muted]="#2a2a2a"
    [fg]="#e0e0e0" [fg2]="#b0b0b0" [fg3]="#ffffff"
    [teal]="#00e5ff" [cyan]="#00b8d4" [blue]="#2979ff" [dark_blue]="#1565c0"
    [red]="#ff1744" [orange]="#ff9100" [yellow]="#ffea00" [green]="#00e676" [purple]="#d500f9"
)

# Foot colors (no # prefix)
declare -A FOOT_NORD=(
    [bg]="2e3440" [surface]="3b4252" [surface2]="434c5e" [muted]="4c566a"
    [fg]="d8dee9" [fg2]="e5e9f0" [fg3]="eceff4"
    [teal]="8fbcbb" [cyan]="88c0d0" [blue]="81a1c1" [dark_blue]="5e81ac"
    [red]="bf616a" [orange]="d08770" [yellow]="ebcb8b" [green]="a3be8c" [purple]="b48ead"
)

declare -A FOOT_CTP=(
    [bg]="1e1e2e" [surface]="313244" [surface2]="45475a" [muted]="585b70"
    [fg]="cdd6f4" [fg2]="bac2de" [fg3]="a6adc8"
    [teal]="94e2d5" [cyan]="89dceb" [blue]="89b4fa" [dark_blue]="74c7ec"
    [red]="f38ba8" [orange]="fab387" [yellow]="f9e2af" [green]="a6e3a1" [purple]="cba6f7"
)

declare -A FOOT_GRUV=(
    [bg]="1d2021" [surface]="282828" [surface2]="32302f" [muted]="504945"
    [fg]="ebdbb2" [fg2]="d5c4a1" [fg3]="fbf1c7"
    [teal]="689d6a" [cyan]="8ec07c" [blue]="458588" [dark_blue]="83a598"
    [red]="cc241d" [orange]="d65d0e" [yellow]="d79921" [green]="98971a" [purple]="b16286"
)

declare -A FOOT_BLACK=(
    [bg]="000000" [surface]="0d0d0d" [surface2]="1a1a1a" [muted]="2a2a2a"
    [fg]="e0e0e0" [fg2]="b0b0b0" [fg3]="ffffff"
    [teal]="00e5ff" [cyan]="00b8d4" [blue]="2979ff" [dark_blue]="1565c0"
    [red]="ff1744" [orange]="ff9100" [yellow]="ffea00" [green]="00e676" [purple]="d500f9"
)

# Build mapping: each theme has a nord->theme mapping
build_map() {
    local -n t="$1"
    for key in "${!NORD[@]}"; do
        echo "${NORD[$key]}:${t[$key]}"
    done
}

get_palette() {
    case "$1" in nord) echo "NORD" ;; catppuccin) echo "CTP" ;; gruvbox) echo "GRUV" ;; black) echo "BLACK" ;; esac
}

get_foot_palette() {
    case "$1" in nord) echo "FOOT_NORD" ;; catppuccin) echo "FOOT_CTP" ;; gruvbox) echo "FOOT_GRUV" ;; black) echo "FOOT_BLACK" ;; esac
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

apply_foot_theme() {
    local file="$1" from="$2" to="$3"
    [[ ! -f "$file" ]] && return
    local from_arr=$(get_foot_palette "$from")
    local to_arr=$(get_foot_palette "$to")
    local -n f="$from_arr" t="$to_arr"
    for key in "${!f[@]}"; do
        sed -i "s/${f[$key]}/${t[$key]}/gi" "$file"
    done
}

# ── Boxxy (black theme) style overrides ─────────────────────

apply_boxxy() {
    local font_css="Iosevka Nerd Font"
    local font_term="Iosevka Nerd Font"
    local font_rasi="Iosevka Nerd Font 12"

    # Rofi
    sed -i 's/border-radius: *[0-9]*px/border-radius: 0px/g' "${C}/rofi/themes/nordic.rasi"
    sed -i "s/font:.*/font: \"${font_rasi}\";/" "${C}/rofi/themes/nordic.rasi"

    # Waybar
    sed -i 's/border-radius: *[0-9]*px/border-radius: 0px/g' "${C}/waybar/style.css"
    sed -i "s/font-family:.*/font-family: '${font_css}';/" "${C}/waybar/style.css"

    # Dunst
    sed -i 's/corner_radius = [0-9]*/corner_radius = 0/' "${C}/dunst/dunstrc"
    sed -i "s/font =.*/font = ${font_css} 10/" "${C}/dunst/dunstrc"

    # Kitty
    sed -i "s/font_family.*/font_family ${font_term}/" "${C}/kitty/kitty.conf"
    sed -i "s/bold_font.*/bold_font ${font_term} Bold/" "${C}/kitty/kitty.conf"
    sed -i "s/italic_font.*/italic_font ${font_term} Italic/" "${C}/kitty/kitty.conf"
    sed -i "s/bold_italic_font.*/bold_italic_font ${font_term} Bold Italic/" "${C}/kitty/kitty.conf"

    # Hyprland
    sed -i 's/rounding *= *[0-9]*/rounding = 0/' "${C}/hypr/hyprland.lua"
    sed -i "s/font_family.*/font_family ${font_term}/" "${C}/hypr/hyprland.lua"
}

remove_boxxy() {
    local def_font_css="JetBrainsMono Nerd Font"
    local def_font_term="JetBrainsMono Nerd Font"
    local def_font_rasi="JetBrainsMono Nerd Font 12"
    local def_rounding="2"

    # Rofi - restore rounded corners and font
    sed -i 's/border-radius: 0px/border-radius: 14px/g' "${C}/rofi/themes/nordic.rasi"
    sed -i 's/border-radius: 14px/    border-radius: 14px;/g' "${C}/rofi/themes/nordic.rasi"
    # More targeted: window, mainbox, inputbar, listview, message
    sed -i "/^window {/,/^}/ s/border-radius: 14px/border-radius: 14px/" "${C}/rofi/themes/nordic.rasi"
    sed -i "/^mainbox {/,/^}/ s/border-radius: 12px/border-radius: 12px/" "${C}/rofi/themes/nordic.rasi"
    sed -i "/^inputbar {/,/^}/ s/border-radius: 12px 12px 0 0/border-radius: 12px 12px 0 0/" "${C}/rofi/themes/nordic.rasi"
    sed -i "/^listview {/,/^}/ s/border-radius: 0 0 12px 12px/border-radius: 0 0 12px 12px/" "${C}/rofi/themes/nordic.rasi"
    sed -i "/^element {/,/^}/ s/border-radius: 10px/border-radius: 10px/" "${C}/rofi/themes/nordic.rasi"
    sed -i "/^message {/,/^}/ s/border-radius: 0 0 12px 12px/border-radius: 0 0 12px 12px/" "${C}/rofi/themes/nordic.rasi"
    sed -i "s/font:.*/font: \"${def_font_rasi}\";/" "${C}/rofi/themes/nordic.rasi"

    # Waybar
    sed -i '/window/,/^}/ s/border-radius: 0px/border-radius: 10px/g' "${C}/waybar/style.css"
    sed -i '/tooltip/,/^}/ s/border-radius: 0px/border-radius: 8px/g' "${C}/waybar/style.css"
    sed -i "s/font-family:.*/font-family: '${def_font_css}';/" "${C}/waybar/style.css"

    # Dunst
    sed -i 's/corner_radius = 0/corner_radius = 8/' "${C}/dunst/dunstrc"
    sed -i "s/font =.*/font = ${def_font_css} 10/" "${C}/dunst/dunstrc"

    # Kitty
    sed -i "s/font_family.*/font_family ${def_font_term}/" "${C}/kitty/kitty.conf"
    sed -i "s/bold_font.*/bold_font ${def_font_term} Bold/" "${C}/kitty/kitty.conf"
    sed -i "s/italic_font.*/italic_font ${def_font_term} Italic/" "${C}/kitty/kitty.conf"
    sed -i "s/bold_italic_font.*/bold_italic_font ${def_font_term} Bold Italic/" "${C}/kitty/kitty.conf"

    # Hyprland
    sed -i "s/rounding = 0/rounding = ${def_rounding}/" "${C}/hypr/hyprland.lua"
    sed -i "s/font_family.*/font_family ${def_font_term}/" "${C}/hypr/hyprland.lua"
}

# ── Main ────────────────────────────────────────────────────

THEMES="nord\ncatppuccin\ngruvbox\nblack"

if [[ "$1" == "menu" ]]; then
    CURRENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "nord")
    THEME=$(printf "$THEMES" | rofi -dmenu -p "Theme" -mesg "Current: ${CURRENT}" -select "$CURRENT")
    [[ -z "$THEME" ]] && exit 0
elif [[ "$1" == "nord" || "$1" == "catppuccin" || "$1" == "gruvbox" || "$1" == "black" ]]; then
    THEME="$1"
else
    CURRENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "nord")
    if [[ "$1" == "toggle" ]]; then
        case "$CURRENT" in
            nord) THEME="catppuccin" ;;
            catppuccin) THEME="gruvbox" ;;
            gruvbox) THEME="black" ;;
            black) THEME="nord" ;;
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
    # Remove boxxy if leaving black
    if [[ "$PREV" == "black" ]]; then
        remove_boxxy
    fi

    # Restore to nord first, then apply new theme
    if [[ "$PREV" != "nord" ]]; then
        for dir in "waybar/style.css" "rofi/themes/nordic.rasi" "kitty/kitty.conf" "dunst/dunstrc"; do
            apply_theme "${C}/${dir}" "$PREV" "nord"
        done
        apply_foot_theme "${C}/foot/foot.ini" "$PREV" "nord"
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
        apply_foot_theme "${C}/foot/foot.ini" "nord" "$THEME"
    fi

    # Apply boxxy if switching to black
    if [[ "$THEME" == "black" ]]; then
        apply_boxxy
    fi
fi

# ── Wallpaper directory ────────────────────────────────────

WALL_DIR_NORD="$HOME/Pictures/wallpapers"
WALL_DIR_CTP="$HOME/Pictures/wallpapers-catppuccin"
WALL_DIR_GRUV="$HOME/Pictures/wallpapers-gruvbox"
WALL_DIR_BLACK="$HOME/Pictures/wallpapers-nord"

case "$THEME" in
    catppuccin) WDIR="$WALL_DIR_CTP" ;;
    gruvbox)    WDIR="$WALL_DIR_GRUV" ;;
    black)      WDIR="$WALL_DIR_BLACK" ;;
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
    gruvbox)    GTK_THEME="Gruvbox" ;;
    black)      GTK_THEME="Nordic" ;;
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

notify-send "Theme" "Switched to Boxxy Black"
