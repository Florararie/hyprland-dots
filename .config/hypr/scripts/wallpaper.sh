#!/usr/bin/env bash

WALLDIR=~/.config/hypr/images/wallpapers
CONF=~/.config/hypr/hyprpaper.conf
THEME=~/.config/hypr/rofi/main.rasi

mapfile -t WALLS < <(ls -1 "$WALLDIR")
[ "${#WALLS[@]}" -eq 0 ] && exit 1

WALL_CHOICE=$(printf '%s\n' "${WALLS[@]}" | \
    rofi -dmenu -i -p "Wallpaper:" -theme "$THEME")

[ -z "$WALL_CHOICE" ] && exit 0
WALL_PATH="$WALLDIR/$WALL_CHOICE"

mapfile -t MONITORS < <(
    hyprctl monitors | awk '/Monitor/ {print $2}'
)

if [ "${#MONITORS[@]}" -eq 1 ]; then
    MON_CHOICE="${MONITORS[0]}"
else
    MON_CHOICE=$(printf '%s\n' "${MONITORS[@]}" | \
        rofi -dmenu -i -p "Monitor:" -theme "$THEME")
    [ -z "$MON_CHOICE" ] && exit 0
fi

FIT_MODES=(cover contain fill tile)
FIT_CHOICE=$(printf '%s\n' "${FIT_MODES[@]}" | \
    rofi -dmenu -i -p "Fit mode:" -theme "$THEME")

[ -z "$FIT_CHOICE" ] && exit 0

hyprctl hyprpaper wallpaper "$MON_CHOICE, $WALL_PATH, $FIT_CHOICE"

if [ ! -f "$CONF" ]; then
    cat > "$CONF" <<EOF
splash = false
ipc = true
EOF
fi

sed -i "/wallpaper {/,/}/ { /monitor = $MON_CHOICE/ { d; }; /wallpaper {/ { :a; N; /}/! ba; /monitor = $MON_CHOICE/d; } }" "$CONF"
sed -i '/^$/N; /^\n$/D' "$CONF"
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CONF"
cat >> "$CONF" <<EOF

wallpaper {
    monitor = $MON_CHOICE
    path = $WALL_PATH
    fit_mode = $FIT_CHOICE
}
EOF