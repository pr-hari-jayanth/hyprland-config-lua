#!/bin/bash
# Hyprland dotfiles installer — handles fresh EndeavourOS/Arch systems

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "=== Hyprland dotfiles installer ==="
echo ""

# ── 1. Packages ──────────────────────────────────────────────────────

echo "[1/5] Installing packages..."

PKGS=(
    hyprland waybar rofi kitty dunst swaybg
    mpd rmpc hyprsunset
    flameshot grim slurp wl-clipboard
    network-manager-applet bluez-utils
    xsettingsd polkit-gnome
    thunar ffmpeg firefox neovim
    curl unzip git base-devel
    otf-font-awesome ttf-jetbrains-mono-nerd
)

sudo pacman -S --needed --noconfirm "${PKGS[@]}" || {
    echo "Warning: some pacman packages failed, continuing..."
}

# AUR helper
if ! command -v paru &>/dev/null && ! command -v yay &>/dev/null; then
    echo "Installing paru (AUR helper)..."
    (
        cd /tmp && rm -rf paru
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru && makepkg -si --noconfirm
    ) || echo "Warning: paru install failed, skipping AUR packages"
fi

AUR_HELPER=$(command -v paru || command -v yay)
if [[ -n "$AUR_HELPER" ]]; then
    $AUR_HELPER -S --needed --noconfirm bibata-cursor-theme-bin 2>/dev/null || true
fi

# ── 2. Themes & Assets ──────────────────────────────────────────────

echo "[2/5] Downloading themes and wallpapers..."

mkdir -p "$HOME/.themes" "$HOME/.local/bin" "$HOME/.fonts" "$HOME/Pictures"

# Nordic GTK theme
if [[ ! -d "$HOME/.themes/Nordic" ]]; then
    echo "  Nordic GTK theme..."
    curl -fsSL "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz" -o /tmp/nordic-gtk.tar.xz 2>/dev/null \
        && tar xf /tmp/nordic-gtk.tar.xz -C "$HOME/.themes/" 2>/dev/null \
        || echo "  Warning: Nordic theme download failed"
fi

# Catppuccin Mocha GTK theme
if [[ ! -d "$HOME/.themes/Catppuccin-Mocha" ]]; then
    echo "  Catppuccin Mocha GTK theme..."
    curl -fsSL "https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-blue-standard%2Bdefault.zip" -o /tmp/catppuccin-gtk.zip 2>/dev/null \
        && unzip -o /tmp/catppuccin-gtk.zip -d "$HOME/.themes/" 2>/dev/null \
        && mv "$HOME/.themes/catppuccin-mocha-blue-standard+default" "$HOME/.themes/Catppuccin-Mocha" 2>/dev/null \
        && sed -i 's/Name=.*/Name=Catppuccin-Mocha/' "$HOME/.themes/Catppuccin-Mocha/index.theme" 2>/dev/null \
        || echo "  Warning: Catppuccin theme download failed"
fi

# Gruvbox GTK theme
if [[ ! -d "$HOME/.themes/Gruvbox" ]]; then
    echo "  Gruvbox GTK theme..."
    if git clone --depth=1 https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git /tmp/gruvbox-gtk 2>/dev/null; then
        if git clone --depth=1 https://github.com/sass/libsass.git /tmp/libsass 2>/dev/null \
           && git clone --depth=1 https://github.com/sass/sassc.git /tmp/sassc 2>/dev/null \
           && make -C /tmp/libsass -j$(nproc) 2>/dev/null \
           && make -C /tmp/sassc SASS_LIBSASS_PATH=/tmp/libsass -j$(nproc) 2>/dev/null; then
            cp /tmp/sassc/bin/sassc "$HOME/.local/bin/"
            export PATH="$HOME/.local/bin:$PATH"
            (
                cd /tmp/gruvbox-gtk/themes
                ./build.sh 2>/dev/null && ./install.sh -c dark -n Gruvbox --dest "$HOME/.themes" 2>/dev/null
            )
            mv "$HOME/.themes/Gruvbox-Dark" "$HOME/.themes/Gruvbox" 2>/dev/null || true
            mv "$HOME/.themes/Gruvbox-Dark-hdpi" "$HOME/.themes/Gruvbox-hdpi" 2>/dev/null || true
            mv "$HOME/.themes/Gruvbox-Dark-xhdpi" "$HOME/.themes/Gruvbox-xhdpi" 2>/dev/null || true
            [[ -f "$HOME/.themes/Gruvbox/index.theme" ]] && sed -i 's/Name=Gruvbox-Dark/Name=Gruvbox/' "$HOME/.themes/Gruvbox/index.theme" 2>/dev/null || true
        else
            echo "  Warning: Failed to build sassc, skipping Gruvbox theme"
        fi
    else
        echo "  Warning: Failed to clone Gruvbox theme repo"
    fi
fi

# Blackout GTK theme (from dotfiles)
if [[ ! -d "$HOME/.themes/Blackout" && -d "$DOTFILES/.themes/Blackout" ]]; then
    echo "  Blackout GTK theme..."
    cp -r "$DOTFILES/.themes/Blackout" "$HOME/.themes/"
fi

# ── Wallpapers ──────────────────────────────────────────────────────

echo "  Wallpapers..."

if [[ ! -d "$HOME/Pictures/wallpapers" ]]; then
    git clone --depth=1 https://github.com/linuxdotexe/nordic-wallpapers.git /tmp/nordic-walls 2>/dev/null \
        && mkdir -p "$HOME/Pictures/wallpapers" \
        && cp /tmp/nordic-walls/wallpapers/* "$HOME/Pictures/wallpapers/" 2>/dev/null \
        || echo "  Warning: Nordic wallpapers failed"
fi

if [[ ! -d "$HOME/Pictures/wallpapers-catppuccin" ]]; then
    git clone --depth=1 https://github.com/orangci/walls-catppuccin-mocha.git "$HOME/Pictures/wallpapers-catppuccin" 2>/dev/null \
        || echo "  Warning: Catppuccin wallpapers failed"
fi

if [[ ! -d "$HOME/Pictures/wallpapers-gruvbox" ]]; then
    git clone --depth=1 https://github.com/AngelJumbo/gruvbox-wallpapers.git /tmp/gruvbox-walls 2>/dev/null \
        && mkdir -p "$HOME/Pictures/wallpapers-gruvbox" \
        && cp -r /tmp/gruvbox-walls/wallpapers/* "$HOME/Pictures/wallpapers-gruvbox/" 2>/dev/null \
        || echo "  Warning: Gruvbox wallpapers failed"
fi

mkdir -p "$HOME/Pictures/wallpapers-black"

# ── Fonts ───────────────────────────────────────────────────────────

echo "  Fonts..."

if [[ ! -d "$HOME/.fonts/Iosevka Nerd Font" ]]; then
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip" -o /tmp/iosevka.zip 2>/dev/null \
        && unzip -o /tmp/iosevka.zip -d "$HOME/.fonts/Iosevka Nerd Font/" 2>/dev/null \
        && fc-cache -f \
        || echo "  Warning: Iosevka font install failed"
fi

# ── 3. Config files ─────────────────────────────────────────────────

echo "[3/5] Installing config files..."

# Backup any existing real config dirs (before we overwrite with symlinks)
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
BACKED_UP=false

for dir in "$DOTFILES"/.config/*/; do
    name=$(basename "$dir")
    target="$HOME/.config/$name"
    # If it exists as a real dir (not a symlink), back it up
    if [[ -d "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        BACKED_UP=true
    fi
done

if $BACKED_UP; then
    echo "  Old configs backed up to $BACKUP_DIR"
fi

# Create symlinks for all config dirs
for dir in "$DOTFILES"/.config/*/; do
    name=$(basename "$dir")
    target="$HOME/.config/$name"
    rm -rf "$target" 2>/dev/null
    ln -sfn "$dir" "$target"
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
