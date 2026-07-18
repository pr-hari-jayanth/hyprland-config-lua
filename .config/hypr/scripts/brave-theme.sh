#!/bin/bash
# Brave: use system GTK theme + set font to match current system font
# Usage: brave-theme.sh [font_name]

BRAVE_CONFIG="${HOME}/.config/BraveSoftware/Brave-Origin-Beta/Default/Preferences"

if [[ -z "$1" ]]; then
    echo "Usage: $0 <font_name>"
    echo "  font_name: Font name to use in Brave (e.g. 'Iosevka Nerd Font')"
    exit 1
fi

FONT_NAME="$1"

if [[ ! -f "$BRAVE_CONFIG" ]]; then
    notify-send "Brave Theme" "Brave config not found at $BRAVE_CONFIG"
    exit 1
fi

export BRAVE_CONFIG FONT_NAME
python3 << 'PYEOF'
import json, os

config = os.environ['BRAVE_CONFIG']
font_name = os.environ['FONT_NAME']

with open(config) as f:
    prefs = json.load(f)

# Enable system GTK theme (not custom extension)
prefs.setdefault('extensions', {}).setdefault('theme', {})
prefs['extensions']['theme']['id'] = ""
prefs['extensions']['theme']['system_theme'] = 1
prefs['extensions']['theme']['use_system'] = True

# Dark mode
prefs.setdefault('browser', {}).setdefault('theme', {})
prefs['browser']['theme']['color_scheme2'] = 2
prefs['browser']['theme']['follows_system_colors'] = True

# Set font to match system font
wp = prefs.setdefault('webkit', {}).setdefault('webprefs', {})
wp.setdefault('fonts', {}).setdefault('Zyyy', {})
wp['fonts']['Zyyy']['standard'] = font_name
wp['fonts']['Zyyy']['fixed'] = font_name
wp['fonts']['Zyyy']['serif'] = font_name
wp['fonts']['Zyyy']['sansserif'] = font_name
wp['fonts']['Zyyy']['cursive'] = font_name
wp['fonts']['Zyyy']['fantasy'] = font_name
wp['default_font_size'] = 14
wp['default_fixed_font_size'] = 13

with open(config, 'w') as f:
    json.dump(prefs, f, indent=2)

print(f"Brave: GTK theme enabled, font set to {font_name}")
PYEOF
