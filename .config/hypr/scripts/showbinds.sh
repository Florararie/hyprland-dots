#!/usr/bin/env bash


THEME=~/.config/hypr/rofi/main.rasi
KEYBINDS_CONF=~/.config/hypr/config.d/keybinds.conf


keybinds=$(grep -E '^\s*bind' "$KEYBINDS_CONF")
if [[ -z "$keybinds" ]]; then
    rofi -dmenu -i -p "No keybinds found." -theme "$THEME"
    exit 1
fi


display_keybinds=$(echo "$keybinds" |
    sed 's/\$mainMod/SUPER/g' |
    sed 's/exec,//g' |
    sed 's/,/, /g' |
    sed 's/  / /g')


# This is so fucking overkill lmao
# But fuck it, we ball
focused_monitor_id=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.monitorID' 2>/dev/null)
screen_width=$(hyprctl monitors -j 2>/dev/null | jq -r ".[] | select(.id == $focused_monitor_id) | .width" 2>/dev/null)

if [[ -z "$screen_width" || "$screen_width" == "null" ]]; then
    screen_width=1920
fi

max_chars=$(echo "$display_keybinds" | awk '{ if (length > L) L=length } END { print L }')
width_px=$(( max_chars * 9 + 120 ))

if (( width_px > screen_width - 200 )); then
    width_px=$(( screen_width - 200 ))
elif (( width_px < 600 )); then
    width_px=600
fi


echo "$display_keybinds" | rofi -dmenu -i -p "Keybinds:" -theme "$THEME" -theme-str "window { width: ${width_px}px; } listview { lines: 10; }"
