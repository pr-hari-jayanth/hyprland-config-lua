#!/bin/bash
# Set Brave Origin Beta theme to match current theme-switcher theme
# Requires: themes loaded once as unpacked extensions in brave://extensions

BRAVE_CONFIG="${HOME}/.config/BraveSoftware/Brave-Origin-Beta/Default/Preferences"
BRAVE_BIN="/opt/brave.com/brave-origin-beta/brave-origin-beta"
THEME_DIR="${HOME}/.config/brave-themes"

get_ext_id() {
    case "$1" in
        nord)        cat "${THEME_DIR}/nord/id.txt" 2>/dev/null || echo "ooapklbilecbiabkfpoppoebgeloolbo" ;;
        catppuccin)  cat "${THEME_DIR}/catppuccin/id.txt" 2>/dev/null || echo "hbbelmlhjmdapckbpeebgodfocomofhg" ;;
        retro)       cat "${THEME_DIR}/retro/id.txt" 2>/dev/null || echo "ppnchhcfompcnphekpgjicfpmepjjigg" ;;
        *)           echo "" ;;
    esac
}

if [[ -z "$1" ]]; then
    echo "Usage: $0 <nord|catppuccin|retro>"
    exit 1
fi

EXT_ID=$(get_ext_id "$1")
THEME_NAME="$1"

if pgrep -af "${BRAVE_BIN}" | grep -v "brave-theme" &>/dev/null; then
    notify-send "Brave Theme" "Restart Brave to apply ${THEME_NAME^} theme"
    exit 0
fi

if [[ ! -f "$BRAVE_CONFIG" ]]; then
    notify-send "Brave Theme" "Brave config not found at $BRAVE_CONFIG"
    exit 1
fi

export BRAVE_CONFIG EXT_ID THEME_NAME
python3 << 'PYEOF'
import json, os

config = os.environ['BRAVE_CONFIG']
ext_id = os.environ['EXT_ID']
theme_name = os.environ['THEME_NAME']

with open(config) as f:
    prefs = json.load(f)

ext_settings = prefs.get('extensions', {}).get('settings', {})
loaded = ext_id in ext_settings

if loaded:
    prefs.setdefault('extensions', {}).setdefault('theme', {})
    prefs['extensions']['theme']['id'] = ext_id
    prefs['extensions']['theme']['system_theme'] = 0
    prefs.setdefault('browser', {}).setdefault('theme', {})
    prefs['browser']['theme']['color_scheme2'] = 4
    print(f"Brave theme set to {theme_name}")
else:
    prefs.setdefault('extensions', {}).setdefault('theme', {})
    prefs['extensions']['theme']['system_theme'] = 1
    print(f"Brave theme extensions not loaded yet. Load unpacked in brave://extensions:")
    print(f"  {os.path.expanduser('~')}/.config/brave-themes/{theme_name}/")
    print(f"Brave will follow GTK dark mode (system theme) until loaded.")

with open(config, 'w') as f:
    json.dump(prefs, f, indent=2)
PYEOF
