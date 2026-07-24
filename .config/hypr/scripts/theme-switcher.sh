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

get_palette() {
    case "$1" in nord) echo "NORD" ;; catppuccin) echo "CTP" ;; gruvbox) echo "GRUV" ;; black) echo "BLACK" ;; esac
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


# ── Boxxy (black theme) style overrides ─────────────────────

apply_boxxy() {
    local font_css="Iosevka Nerd Font"
    local font_term="Iosevka Nerd Font"
    local font_rasi="Iosevka Nerd Font 12"

    # Rofi
    sed -i 's/border-radius: *[0-9]*px/border-radius: 0px/g' "${C}/rofi/themes/nordic.rasi"
    sed -i "s/font:.*/font: \"${font_rasi}\";/" "${C}/rofi/themes/nordic.rasi"

    # Waybar - swap to black monochrome style (bottom position, numbers, no mpd)
    cp "${C}/waybar/style-black.css" "${C}/waybar/style.css"
    cp "${C}/waybar/config-black.jsonc" "${C}/waybar/config.jsonc"

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
    sed -i "s/font:.*/font: \"${def_font_rasi}\";/" "${C}/rofi/themes/nordic.rasi"

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
    THEME=$(printf "$THEMES" | rofi -dmenu -p "Theme" -mesg "Current: ${CURRENT}" -select "$CURRENT" \
        -theme-str 'window {width: 240px; location: center; anchor: center;} inputbar {spacing: 0; padding: 6px 0; children: [textbox-search, entry];} listview {lines: 4; spacing: 0; padding: 0; columns: 1;} element {padding: 0; orientation: vertical;} element-text {padding: 10px 0; horizontal-align: 0.5;} element-icon {size: 0px;} message {padding: 4px 0 6px;} textbox {horizontal-align: 0.5;} entry {horizontal-align: 0.5;} textbox-search {horizontal-align: 0.5;}')
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

    # Restore to nord first for non-waybar files
    if [[ "$PREV" != "nord" ]]; then
        for dir in "rofi/themes/nordic.rasi" "kitty/kitty.conf" "dunst/dunstrc"; do
            apply_theme "${C}/${dir}" "$PREV" "nord"
        done
    fi

    # Swap hyprland color palette (nordic.lua always gets the active theme)
    if [[ "$THEME" == "nord" ]]; then
        cp "${C}/hypr/nord.lua" "${C}/hypr/nordic.lua"
    else
        cp "${C}/hypr/${THEME}.lua" "${C}/hypr/nordic.lua"
    fi

    # Always restore waybar from clean templates for non-black themes
    if [[ "$THEME" != "black" ]]; then
        cp "${C}/waybar/.style-nord-template.css" "${C}/waybar/style.css"
        cp "${C}/waybar/.config-nord-template.jsonc" "${C}/waybar/config.jsonc"
    fi

    # Apply new theme colors (sed on top of clean templates)
    if [[ "$THEME" != "nord" ]]; then
        for dir in "waybar/style.css" "rofi/themes/nordic.rasi" "kitty/kitty.conf" "dunst/dunstrc"; do
            apply_theme "${C}/${dir}" "nord" "$THEME"
        done
    fi

    # Apply boxxy if switching to black (overwrites templates with black files)
    if [[ "$THEME" == "black" ]]; then
        apply_boxxy
    fi
fi

# ── Wallpaper directory ────────────────────────────────────

WALL_DIR_NORD="$HOME/Pictures/wallpapers"
WALL_DIR_CTP="$HOME/Pictures/wallpapers-catppuccin"
WALL_DIR_GRUV="$HOME/Pictures/wallpapers-gruvbox"
WALL_DIR_BLACK="$HOME/Pictures/wallpapers-black"

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
    black)      GTK_THEME="Blackout" ;;
    *)          GTK_THEME="Nordic" ;;
esac

sed -i "s/gtk-theme-name=.*/gtk-theme-name=${GTK_THEME}/" "${C}/gtk-3.0/settings.ini"
sed -i "s/gtk-theme-name=.*/gtk-theme-name=${GTK_THEME}/" "${C}/gtk-4.0/settings.ini" 2>/dev/null || true
sed -i "s/Net\/ThemeName \".*\"/Net\/ThemeName \"${GTK_THEME}\"/" "${C}/xsettingsd/xsettingsd.conf"
killall xsettingsd 2>/dev/null || true
${HOME}/.local/bin/xsettingsd &>/dev/null &
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true

# ── Brave theme ────────────────────────────────────────────

BRAVE_FONT="JetBrainsMono Nerd Font"
[[ "$THEME" == "black" ]] && BRAVE_FONT="Iosevka Nerd Font"
"${C}/hypr/scripts/brave-theme.sh" "$BRAVE_FONT" 2>/dev/null || true

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
