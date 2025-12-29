#!/bin/bash

set -euo pipefail
trap 'echo "❌ Setup failed. Check the output above."' ERR


CONFIG_DIR="$HOME/.config"
REPO_DIR="$HOME/hyprland-dots"
PARU_BUILD_DIR="$HOME/.cache/paru-build"
REPO_URL="https://github.com/Florararie/hyprland-dots"


backup_if_exists() {
    local target="$1"
    [ -e "$target" ] || return 0
    local backup="${target}.bak"
    local i=1
    if [ -e "$backup" ]; then
        while [ -e "${backup} (${i})" ]; do
            ((i++))
        done
        backup="${backup} (${i})"
    fi
    echo "Backing up $target to $backup"
    mv "$target" "$backup"
}


read -rp "Update package list? [y/N]: " update_choice
if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    sudo -v
    sudo pacman -Syy
fi


pacman_packages=(
    firefox
    alacritty
    pcmanfm-qt
    hyprpaper
    hypridle
    hyprpolkitagent
    hyprlock
    hyprshot
    rofi
    plasma-systemmonitor
    ttf-jetbrains-mono
)


aur_packages=(
    ags-hyprpanel-git
)


echo ""
read -rp "Install Pacman packages? [y/N]: " install_choice
if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    sudo -v
    for package in "${pacman_packages[@]}"; do
        sudo pacman -S --needed --noconfirm "$package"
    done
fi


echo ""
read -rp "Install AUR packages? [y/N]: " aur_choice
if [[ "$aur_choice" =~ ^[Yy]$ ]]; then
    if ! command -v paru &> /dev/null; then
        rm -rf "$PARU_BUILD_DIR"
        mkdir -p "$PARU_BUILD_DIR"
        git clone https://aur.archlinux.org/paru.git "$PARU_BUILD_DIR"
        makepkg -si --noconfirm --dir "$PARU_BUILD_DIR"
        rm -rf "$PARU_BUILD_DIR"
    fi

    sudo -v
    for package in "${aur_packages[@]}"; do
        paru -S --needed --noconfirm "$package"
    done
fi


echo ""
if [ -d "$REPO_DIR/.git" ]; then
    echo "Updating existing hyprland-dots repo..."
    git -C "$REPO_DIR" diff --quiet || echo "⚠️  Local changes detected"
    git -C "$REPO_DIR" pull --ff-only
else
    echo "Cloning hyprland dots..."
    rm -rf "$REPO_DIR"
    git clone "$REPO_URL" "$REPO_DIR"
fi


if [ ! -d "$REPO_DIR/.config/hypr" ]; then
    echo ""
    echo "Error: hypr config not found in repo"
    exit 1
fi


echo ""
mkdir -p "$CONFIG_DIR"
backup_if_exists "$CONFIG_DIR/hypr"
backup_if_exists "$CONFIG_DIR/gtk-3.0"
backup_if_exists "$CONFIG_DIR/gtk-4.0"


rsync -a "$REPO_DIR/.config/hypr/" "$CONFIG_DIR/hypr/"
[ -L "$CONFIG_DIR/gtk-3.0" ] && rm "$CONFIG_DIR/gtk-3.0"
[ -L "$CONFIG_DIR/gtk-4.0" ] && rm "$CONFIG_DIR/gtk-4.0"
ln -s "$CONFIG_DIR/hypr/gtk/gtk-3.0" "$CONFIG_DIR/gtk-3.0"
ln -s "$CONFIG_DIR/hypr/gtk/gtk-4.0" "$CONFIG_DIR/gtk-4.0"


echo ""
echo "Hyprland dotfiles setup complete."
echo "Log out and back in to apply all changes."
