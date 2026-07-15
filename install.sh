#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "=== Hyprland dotfiles installer ==="
echo ""

# ── 1. Packages ──────────────────────────────────────────────────────

PKGS=(
    hyprland waybar rofi kitty dunst swaybg
    mpd rmpc hyprsunset
    flameshot grim slurp wl-clipboard
    network-manager-applet bluez-utils
    xsettingsd polkit-gnome
    thunar ffmpeg firefox neovim
    curl unzip git base-devel
    ttf-hack ttf-font-awesome
)

echo "[1/5] Installing packages..."
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

if ! command -v paru &>/dev/null && ! command -v yay &>/dev/null; then
    echo "Installing paru (AUR helper)..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    cd "$DOTFILES"
fi
AUR_HELPER=$(command -v paru || command -v yay)

# AUR packages
$AUR_HELPER -S --needed --noconfirm bibata-cursor-theme-bin 2>/dev/null || true
$AUR_HELPER -S --needed --noconfirm hyprsunset 2>/dev/null || true

# ── 2. Themes & Assets ──────────────────────────────────────────────

echo "[2/5] Downloading themes and wallpapers..."

# Nordic GTK theme
if [[ ! -d "$HOME/.themes/Nordic" ]]; then
    mkdir -p "$HOME/.themes"
    echo "Downloading Nordic GTK theme..."
    curl -L "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz" -o /tmp/nordic-gtk.tar.xz
    tar xf /tmp/nordic-gtk.tar.xz -C "$HOME/.themes/"
fi

# Catppuccin Mocha GTK theme
if [[ ! -d "$HOME/.themes/Catppuccin-Mocha" ]]; then
    echo "Downloading Catppuccin Mocha GTK theme..."
    curl -L "https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-blue-standard%2Bdefault.zip" -o /tmp/catppuccin-gtk.zip
    unzip -o /tmp/catppuccin-gtk.zip -d "$HOME/.themes/"
    mv "$HOME/.themes/catppuccin-mocha-blue-standard+default" "$HOME/.themes/Catppuccin-Mocha"
    sed -i 's/Name=.*/Name=Catppuccin-Mocha/' "$HOME/.themes/Catppuccin-Mocha/index.theme"
fi

# Nordic wallpapers
if [[ ! -d "$HOME/Pictures/wallpapers" ]]; then
    echo "Cloning Nordic wallpapers..."
    git clone --depth=1 https://github.com/linuxdotexe/nordic-wallpapers.git /tmp/nordic-walls
    mkdir -p "$HOME/Pictures/wallpapers"
    cp /tmp/nordic-walls/wallpapers/* "$HOME/Pictures/wallpapers/" 2>/dev/null || true
fi

# Catppuccin wallpapers
if [[ ! -d "$HOME/Pictures/wallpapers-catppuccin" ]]; then
    echo "Cloning Catppuccin wallpapers..."
    git clone --depth=1 https://github.com/orangci/walls-catppuccin-mocha.git "$HOME/Pictures/wallpapers-catppuccin"
fi

# Retro wallpapers
if [[ ! -d "$HOME/Pictures/wallpapers-retro" ]]; then
    echo "Downloading retro wallpapers..."
    mkdir -p "$HOME/Pictures/wallpapers-retro"
    git clone --depth=1 https://github.com/D3Ext/aesthetic-wallpapers.git /tmp/aesthetic-walls
    for f in gruvbox_retrocity retro_city retro_market retro2_live retro_live \
        neocity neocity2 neon-car2 neon-circle neon-lights neon-shacks-nord \
        pixel_big_city pixel-city sunset_city plane_sunset nord_dark_city \
        sunset-xfksfuywx japan_anime_city cityscape-sunset-nord \
        abstract beach_landscape mountains needing-space ocean_with_cloud \
        purple-mountain shape-abstract; do
        find /tmp/aesthetic-walls/images/ -name "${f}.*" -exec cp {} "$HOME/Pictures/wallpapers-retro/" \; 2>/dev/null || true
    done
fi

# Dot cursor (light)
if [[ ! -d "$HOME/.icons/Dot-Light" ]]; then
    echo "Downloading TheDot cursor..."
    mkdir -p "$HOME/.icons"
    curl -L "https://files06.pling.com/api/files/download/j/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTU0Nzc2Mjc1OCwibyI6IjEiLCJzIjoiNmU2YTNjY2IwMjYyMmM5MjFmZWZiYzI3OTJmOTlhMDY3Yjc4ZjQ5ZjU4Njc3NzRhZTllZmFmYjliNjIxOTg3YzU0MDgyODNmZmE3MmJiYTVlMGQ3YzJiMmI2OTNhYjQyZGQ5OWNhYzA2NmQxZjI1NmYzOTBmNjQwOTc2YjI3ZDAiLCJ0IjoxNzgzMDk0MjMwLCJzdGZwIjpudWxsLCJzdGlwIjoiMTA2LjUxLjE3NS4xMDEifQ.pQsfC62gPjlrJa-Bw1IE8FIq7CqCZD-a7GHb1KHyKpw/thedot0.6.tar.gz" -o /tmp/thedot.tar.gz
    tar xzf /tmp/thedot.tar.gz -C /tmp/
    cp -r /tmp/thedot/thedot0.6/Dot-Light "$HOME/.icons/"
fi

# ── 3. Config files ─────────────────────────────────────────────────

echo "[3/5] Installing config files..."

# Backup existing config
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
for dir in hypr waybar rofi kitty dunst mpd rmpc gtk-3.0 gtk-4.0 xsettingsd; do
    if [[ -d "$HOME/.config/$dir" && ! -L "$HOME/.config/$dir" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

# Symlink all config dirs
for dir in "$DOTFILES"/.config/*/; do
    target="$HOME/.config/$(basename "$dir")"
    ln -sfn "$dir" "$HOME/.config/"
done

mkdir -p "$HOME/.cache"

# ── 4. Services ─────────────────────────────────────────────────────

echo "[4/5] Enabling services..."
sudo systemctl enable bluetooth 2>/dev/null || true
systemctl --user enable mpd 2>/dev/null || true
systemctl --user start mpd 2>/dev/null || true

# ── 5. Done ─────────────────────────────────────────────────────────

echo "[5/5] Installation complete!"
echo ""
echo "Reboot or restart Hyprland to apply."
echo "Keybinds: Super+Shift+K to show help"
echo "Theme switcher: Super+Shift+T"
