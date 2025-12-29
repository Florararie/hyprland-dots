#!/usr/bin/env bash


DELAY=0
THEME=~/.config/hypr/rofi/main.rasi
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"


show_menu() {
    local current_delay=$1
    options=(
        "🖥️  Full Screen"
        "🪟  Current Window"
        "📐  Select Window"
        "✂️  Region"
        "⏱️  Set Delay [${current_delay}s]"
    )

    printf '%s\n' "${options[@]}"
}


set_delay() {
    local current_delay=$1
    while true; do
        delay_input=$(rofi -dmenu -p "Delay (current: ${current_delay}s):" -theme $THEME)
        [ -z "$delay_input" ] && return 1  # User cancelled

        if echo "$delay_input" | grep -qE '^[0-9]+$'; then
            DELAY=$delay_input
            return 0
        else
            rofi -e "❌ Invalid input. Please enter a number - (EG: 5)" -theme $THEME
        fi
    done
}


while true; do
    choice=$(show_menu "$DELAY" | rofi -dmenu -i -p "Screenshot:" -theme $THEME)
    [ -z "$choice" ] && exit 0

    if [[ "$choice" == *"Set Delay"* ]]; then
        if set_delay "$DELAY"; then
            continue
        else
            continue
        fi
    fi
    break
done


if [ "$DELAY" -gt 0 ]; then
    for ((i=DELAY; i>0; i--)); do
        notify-send -t 1000 -a "Hyprshot Countdown" "🕒 Screenshot in ${i}..." &
        sleep 1
    done
fi


wait
sleep 0.5


focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')


case "$choice" in
    "🖥️  Full Screen")
        hyprshot -m output -m "$focused_monitor"
        ;;
    "🪟  Current Window")
        hyprshot -m window -m active
        ;;
    "📐  Select Window")
        hyprshot -m window
        ;;
    "✂️  Region")
        hyprshot -m region
        ;;
esac


[ -f "$SOUND_FILE" ] && paplay "$SOUND_FILE"
wait
