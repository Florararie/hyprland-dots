#!/usr/bin/env bash
#
# Fix KDE applications not opening default applications
# (missing /etc/xdg/menus/applications.menu issue)
#
# Source : https://github.com/prasanthrangan/hyprdots/issues/1406#issuecomment-2082301739


set -euo pipefail
BUILD_OUTPUT=$(kbuildsycoca6 --noincremental 2>&1 || true)


if echo "$BUILD_OUTPUT" | grep -q "applications.menu"; then
    echo "Missing 'applications.menu' in KDE XDG menus."
    echo "Attempting to apply fix..."

    # Ensure we have sudo privileges early
    if ! sudo -v; then
        echo "Unable to obtain sudo privileges. Exiting."
        exit 1
    fi

    echo "Installing 'archlinux-xdg-menu' if not present..."
    sudo pacman -Sy --needed --noconfirm archlinux-xdg-menu

    echo "Updating desktop database..."
    sudo update-desktop-database

    echo "Checking for menu files in /etc/xdg/menus..."
    if [ -f /etc/xdg/menus/arch-applications.menu ] && [ ! -f /etc/xdg/menus/applications.menu ]; then
        echo "Renaming 'arch-applications.menu' -> 'applications.menu'..."
        sudo mv /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu
    else
        echo "Menu files already correct. No rename needed."
    fi

    echo "Rebuilding KDE system configuration cache..."
    kbuildsycoca6 --noincremental

    echo "Fix applied successfully!"
else
    echo "No issues detected. KDE menus are already correctly configured."
fi
