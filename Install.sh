#!/bin/bash

set -euo pipefail
trap 'echo "Setup failed. Check the output above."' ERR


CONFIG_DIR="$HOME/.config"
LOCAL_DIR="$HOME/.local/share"
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
    nwg-look
    pcmanfm-qt
    kitty
    alacritty
    corectrl
    tumbler
    hyprpaper
    hypridle
    hyprpolkitagent
    polkit-kde-agent
    hyprlock
    hyprshutdown
    grim
    slurp
    wl-clipboard
    rofi
    plasma-systemmonitor
    qt5-wayland
    qt6-wayland
    qt5ct
    breeze
    breeze-icons
    breeze-cursors
    ttf-hack
    ttf-jetbrains-mono
)


aur_packages=(
    qt6ct-kde # will replace with hyprqt6engine eventually (maybe?)
    wayle-bin
    noctalia-shell # another option?
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
    git -C "$REPO_DIR" diff --quiet || echo "Local changes detected"
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
mkdir -p "$LOCAL_DIR"
backup_if_exists "$CONFIG_DIR/hypr"
backup_if_exists "$CONFIG_DIR/wayle"
backup_if_exists "$CONFIG_DIR/noctalia"
backup_if_exists "$CONFIG_DIR/qt5ct"
backup_if_exists "$CONFIG_DIR/qt6ct"
backup_if_exists "$CONFIG_DIR/alacritty"
backup_if_exists "$LOCAL_DIR/color-schemes"
backup_if_exists "$LOCAL_DIR/themes"


rsync -a "$REPO_DIR/.config/hypr/" "$CONFIG_DIR/hypr/"
rsync -a "$REPO_DIR/.config/wayle/" "$CONFIG_DIR/wayle/"
rsync -a "$REPO_DIR/.config/noctalia/" "$CONFIG_DIR/noctalia/"
rsync -a "$REPO_DIR/.config/qt5ct/" "$CONFIG_DIR/qt5ct/"
rsync -a "$REPO_DIR/.config/qt6ct/" "$CONFIG_DIR/qt6ct/"
rsync -a "$REPO_DIR/.config/alacritty/" "$CONFIG_DIR/alacritty/"
rsync -a "$REPO_DIR/.local/share/color-schemes/" "$LOCAL_DIR/color-schemes/"
rsync -a "$REPO_DIR/.local/share/themes/" "$LOCAL_DIR/themes/"


echo ""
echo "Hyprland dotfiles setup complete."
echo "Log out and back in to apply all changes."
