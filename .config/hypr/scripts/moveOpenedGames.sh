#!/bin/bash

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
WORKSPACE=2

is_steam_game() {
    local pid=$1

    while [[ "$pid" -ne 1 && -n "$pid" ]]; do
        # Skip processes we don't own
        [[ $(stat -c %u /proc/$pid 2>/dev/null) != $(id -u) ]] && return 1
        
        if tr '\0' '\n' < /proc/$pid/environ 2>/dev/null | \
            grep -qE '^(SteamAppId|SteamGameId|STEAM_COMPAT_APP_ID|SteamOverlayGameId)='; then
            return 0
        fi

        pid=$(awk '/^PPid:/ {print $2}' /proc/$pid/status 2>/dev/null)
    done

    return 1
}

move_if_steam() {
    local addr="$1"
    local pid="$2"

    [[ -z "$pid" || "$pid" == "null" ]] && return

    if is_steam_game "$pid"; then
        title=$(hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.address==\"$addr\") | .title")
        [[ -z "$title" || "$title" == "null" ]] && title="Game (PID: $pid)"
        hyprctl dispatch movetoworkspace $WORKSPACE,address:$addr &>/dev/null
        notify-send -t 5000 "Game Moved" "Moved '$title' to workspace $WORKSPACE"
    fi
}

# existing windows
hyprctl clients -j | jq -r '.[] | "\(.address) \(.pid)"' | while read -r addr pid; do
    move_if_steam "$addr" "$pid"
done

# new windows
socat UNIX-CONNECT:"$SOCKET" - 2>/dev/null | while read -r line; do
    if [[ "$line" == openwindow* ]]; then
        addr="0x${line#*>>}"
        addr="${addr%%,*}"
        pid=$(hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.address==\"$addr\") | .pid")
        move_if_steam "$addr" "$pid"
    fi
done