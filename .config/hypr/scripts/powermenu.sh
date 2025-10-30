#!/usr/bin/env bash


THEME=~/.config/hypr/rofi/main.rasi


show_menu() {
    options=(
        "⏻  Shutdown"
        "  Reboot"
        "  Lock"
        "󰤄  Suspend"
        "  Logout"
    )
    printf '%s\n' "${options[@]}"
}


confirm_action() {
    local action=$1
    rofi -dmenu -i -p "Confirm $action? (y/n)" -theme $THEME | grep -qi '^y$'
}


choice=$(show_menu | rofi -dmenu -i -p "Power Menu:" -theme $THEME)
[ -z "$choice" ] && exit 0


case "$choice" in
    "⏻  Shutdown")
        if confirm_action "shutdown"; then
            systemctl poweroff &
            exit 0
        fi
        ;;
    "  Reboot")
        if confirm_action "reboot"; then
            systemctl reboot &
            exit 0
        fi
        ;;
    "  Lock")
        loginctl lock-session &
        exit 0
        ;;
    "󰤄  Suspend")
        if confirm_action "suspend"; then
            systemctl suspend &
            exit 0
        fi
        ;;
    "  Logout")
        if confirm_action "logout"; then
            hyprctl dispatch exit &
            exit 0
        fi
        ;;
esac
