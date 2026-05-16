#!/usr/bin/env bash

DELAY=0
HIDE_CURSOR=TRUE
THEME=~/.config/hypr/rofi/main.rasi
SAVEDIR=~/Pictures/Screenshots
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"

mkdir -p "$SAVEDIR"

cleanup() {
    maybe_show_cursor
    close_anim_on
    killhyprpicker
}

trap cleanup EXIT

show_menu() {
    local current_delay=$1
    local current_hide=$2
    options=(
        "🖥️  Full Screen"
        "🪟  Current Window"
        "📐  Select Window"
        "✂️  Region"
        "⏱️  Set Delay [${current_delay}s]"
        "🖱️  Hide Cursor [${current_hide}]"
    )
    printf '%s\n' "${options[@]}"
}

set_delay() {
    local current_delay=$1
    while true; do
        delay_input=$(rofi -dmenu -p "Delay (current: ${current_delay}s):" -theme $THEME)
        [ -z "$delay_input" ] && return 1
        if echo "$delay_input" | grep -qE '^[0-9]+$'; then
            DELAY=$delay_input
            return 0
        else
            rofi -e "❌ Invalid input. Please enter a number - (EG: 5)" -theme $THEME
        fi
    done
}

set_hide_cursor() {
    local choice
    choice=$(printf 'TRUE\nFALSE\nCancel\n' | rofi -dmenu -i -p "Hide Cursor:" -theme $THEME)
    case "$choice" in
        TRUE)  HIDE_CURSOR=TRUE  ;;
        FALSE) HIDE_CURSOR=FALSE ;;
        *)     return ;;
    esac
}

freezescreen() {
    hyprpicker -rz &
    sleep 0.2
}

killhyprpicker() {
    pidof -q hyprpicker && pkill hyprpicker
}

cursor_show()    { hyprctl eval 'hl.config({ cursor = { invisible = false } })'; }
cursor_hide()    { hyprctl eval 'hl.config({ cursor = { invisible = true } })'; sleep 0.6; }
close_anim_off() { hyprctl eval 'hl.animation({ leaf = "fadeLayersOut", enabled = false })'; }
close_anim_on()  { hyprctl eval 'hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 6, bezier = "default" })'; }

maybe_hide_cursor() { [ "$HIDE_CURSOR" = TRUE ] && cursor_hide; }
maybe_show_cursor() { [ "$HIDE_CURSOR" = TRUE ] && cursor_show; }

while true; do
    choice=$(show_menu "$DELAY" "$HIDE_CURSOR" | rofi -dmenu -i -p "Screenshot:" -theme $THEME)
    [ -z "$choice" ] && exit 0

    if [[ "$choice" == *"Set Delay"* ]]; then
        set_delay "$DELAY"
        continue
    fi

    if [[ "$choice" == *"Hide Cursor"* ]]; then
        set_hide_cursor
        continue
    fi

    break
done

if [ "$DELAY" -gt 0 ]; then
    for ((i=DELAY; i>0; i--)); do
        notify-send -t 1000 -a "Screenshot Countdown" "🕒 Screenshot in ${i}..."
        sleep 1
    done
fi

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
OUTFILE="$SAVEDIR/screenshot_$TIMESTAMP.png"

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

case "$choice" in
    "🖥️  Full Screen")
        close_anim_off; maybe_hide_cursor
        grim -o "$focused_monitor" "$OUTFILE"
        ;;
    "🪟  Current Window")
        close_anim_off; maybe_hide_cursor
        geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$geom" "$OUTFILE"
        ;;
    "📐  Select Window")
        close_anim_off; freezescreen
        active_workspaces=$(hyprctl monitors -j | jq -r '.[].activeWorkspace.id')
        geom=$(hyprctl clients -j | jq -r --argjson ws "$(echo "$active_workspaces" | jq -Rs '[split("\n")[] | select(. != "") | tonumber]')" \
            '.[] | select(.workspace.id as $id | $ws | index($id)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp)
        killhyprpicker
        [ -z "$geom" ] && { close_anim_on; exit 0; }
        maybe_hide_cursor
        grim -g "$geom" "$OUTFILE"
        ;;
    "✂️  Region")
        close_anim_off; freezescreen
        geom=$(slurp)
        killhyprpicker
        [ -z "$geom" ] && { close_anim_on; exit 0; }
        maybe_hide_cursor
        grim -g "$geom" "$OUTFILE"
        ;;
esac

if [ -f "$OUTFILE" ]; then
    #[ -f "$SOUND_FILE" ] && paplay "$SOUND_FILE" # this can be obnoxious
    wl-copy < "$OUTFILE"
    #notify-send -t 5000 -i "$OUTFILE" "Screenshot" "Saved to: $OUTFILE"
    hyprctl notify -1 5000 "rgb(d699b6)" "Saved to: $OUTFILE"
fi
