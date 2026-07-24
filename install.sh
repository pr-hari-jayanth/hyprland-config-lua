#!/bin/bash
# Hyprland dotfiles installer — fresh EndeavourOS/Arch systems
# Installs packages, themes, wallpapers from pr-hari-jayanth/hyprland-config-wallpapers

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
WALLPAPER_REPO="https://github.com/pr-hari-jayanth/hyprland-config-wallpapers.git"

echo "=== Hyprland dotfiles installer ==="
echo ""

# ── 1. Packages ──────────────────────────────────────────────────────

echo "[1/6] Installing packages..."

PKGS=(
    hyprland waybar rofi kitty dunst swaybg
    mpd rmpc hyprsunset
    grim slurp wl-clipboard
    network-manager-applet bluez-utils
    xsettingsd polkit-gnome
    thunar ffmpeg neovim
    curl unzip git base-devel
    otf-font-awesome ttf-jetbrains-mono-nerd
)

sudo pacman -S --needed --noconfirm "${PKGS[@]}" || {
    echo "Warning: some packages failed, continuing..."
}

# AUR helper
if ! command -v paru &>/dev/null && ! command -v yay &>/dev/null; then
    echo "Installing paru..."
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

# ── 2. Themes & GTK ─────────────────────────────────────────────────

echo "[2/6] Installing GTK themes..."

mkdir -p "$HOME/.themes" "$HOME/.local/bin" "$HOME/.fonts" "$HOME/Pictures"

# Nordic
if [[ ! -d "$HOME/.themes/Nordic" ]]; then
    echo "  Nordic..."
    curl -fsSL "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz" -o /tmp/nordic-gtk.tar.xz 2>/dev/null \
        && tar xf /tmp/nordic-gtk.tar.xz -C "$HOME/.themes/" 2>/dev/null \
        || echo "  Warning: Nordic download failed"
fi

# Catppuccin Mocha
if [[ ! -d "$HOME/.themes/Catppuccin-Mocha" ]]; then
    echo "  Catppuccin Mocha..."
    curl -fsSL "https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-blue-standard%2Bdefault.zip" -o /tmp/catppuccin-gtk.zip 2>/dev/null \
        && unzip -o /tmp/catppuccin-gtk.zip -d "$HOME/.themes/" 2>/dev/null \
        && mv "$HOME/.themes/catppuccin-mocha-blue-standard+default" "$HOME/.themes/Catppuccin-Mocha" 2>/dev/null \
        && sed -i 's/Name=.*/Name=Catppuccin-Mocha/' "$HOME/.themes/Catppuccin-Mocha/index.theme" 2>/dev/null \
        || echo "  Warning: Catppuccin download failed"
fi

# Gruvbox
if [[ ! -d "$HOME/.themes/Gruvbox" ]]; then
    echo "  Gruvbox..."
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
            echo "  Warning: Gruvbox build failed"
        fi
    else
        echo "  Warning: Gruvbox clone failed"
    fi
fi

# Blackout (from dotfiles)
if [[ ! -d "$HOME/.themes/Blackout" && -d "$DOTFILES/.themes/Blackout" ]]; then
    echo "  Blackout..."
    cp -r "$DOTFILES/.themes/Blackout" "$HOME/.themes/"
fi

# ── 3. Fonts ────────────────────────────────────────────────────────

echo "[3/6] Installing fonts..."

if [[ ! -d "$HOME/.fonts/Iosevka Nerd Font" ]]; then
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip" -o /tmp/iosevka.zip 2>/dev/null \
        && unzip -o /tmp/iosevka.zip -d "$HOME/.fonts/Iosevka Nerd Font/" 2>/dev/null \
        && fc-cache -f \
        || echo "  Warning: Iosevka font install failed"
fi

# ── 4. Wallpapers (from pr-hari-jayanth/hyprland-config-wallpapers) ─

echo "[4/6] Downloading wallpapers..."

clone_wallpapers() {
    local repo_dir="$1"
    local dest_dir="$2"
    local subpath="$3"

    if [[ -d "$dest_dir" ]]; then
        echo "  $dest_dir already exists, skipping"
        return
    fi

    echo "  Downloading $(basename "$dest_dir") wallpapers..."
    if git clone --depth=1 "${WALLPAPER_REPO}" /tmp/wallpaper-repo 2>/dev/null; then
        mkdir -p "$dest_dir"
        if [[ -n "$subpath" ]]; then
            # For gruvbox: copy from subdirectories
            cp -r /tmp/wallpaper-repo/${repo_dir}/${subpath}/* "$dest_dir/" 2>/dev/null \
                || cp -r /tmp/wallpaper-repo/${repo_dir}/* "$dest_dir/" 2>/dev/null
        else
            cp -r /tmp/wallpaper-repo/${repo_dir}/* "$dest_dir/" 2>/dev/null
        fi
    else
        echo "  Warning: Failed to clone wallpaper repo for $dest_dir"
    fi
}

clone_wallpapers "nord" "$HOME/Pictures/wallpapers" ""
clone_wallpapers "catppuccin-mocha" "$HOME/Pictures/wallpapers-catppuccin" ""
clone_wallpapers "gruvbox" "$HOME/Pictures/wallpapers-gruvbox" "minimalistic"

# Clean up wallpaper repo clone
rm -rf /tmp/wallpaper-repo

# Black wallpapers dir
mkdir -p "$HOME/Pictures/wallpapers-black"

# ── 5. Config files ─────────────────────────────────────────────────

echo "[5/6] Installing config files..."

# Backup any existing real config dirs
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
BACKED_UP=false

for dir in "$DOTFILES"/.config/*/; do
    name=$(basename "$dir")
    target="$HOME/.config/$name"
    if [[ -d "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        BACKED_UP=true
    fi
done

if $BACKED_UP; then
    echo "  Old configs backed up to $BACKUP_DIR"
fi

# Create symlinks
for dir in "$DOTFILES"/.config/*/; do
    name=$(basename "$dir")
    target="$HOME/.config/$name"
    rm -rf "$target" 2>/dev/null
    ln -sfn "$dir" "$target"
done

mkdir -p "$HOME/.cache"

# ── 6. Apply Nord theme (colors wallpapers everything) ──────────────

echo "[6/6] Applying Nord theme..."

# Set cache so theme-switcher knows we're coming from black theme
echo "black" > /tmp/current-theme

# Run theme-switcher to apply nord (restores waybar templates, kitty, dunst, rofi, hyprland, wallpaper)
bash "$HOME/.config/hypr/scripts/theme-switcher.sh" nord 2>/dev/null

# ── Services ────────────────────────────────────────────────────────

echo "Enabling services..."
sudo systemctl enable bluetooth 2>/dev/null || true
systemctl --user enable mpd 2>/dev/null || true
systemctl --user start mpd 2>/dev/null || true

# ── Done ────────────────────────────────────────────────────────────

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Reboot or restart Hyprland to apply."
echo "Keybinds: Super+Shift+K  |  Theme: Super+Shift+T"
