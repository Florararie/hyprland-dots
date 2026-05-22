#!/bin/bash

WORKSPACE=2
RESET_DELAY=5
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "Error: HYPRLAND_INSTANCE_SIGNATURE is not set. Are you running inside Hyprland?" >&2
    exit 1
fi
if [[ ! -S "$SOCKET" ]]; then
    echo "Error: Hyprland socket not found at $SOCKET" >&2
    exit 1
fi

declare -A NOTIFIED_APPS      # appid -> 1
declare -A APPID_WINDOWS      # appid:addr -> 1
declare -A ADDR_TO_APPID      # addr -> appid
declare -A APPID_CLOSE_TIME   # appid -> epoch when last window closed
declare -A PID_APPID_CACHE    # pid -> appid ("" = not a Steam game, cached miss)

get_steam_appid() {
    local pid=$1

    if [[ -v PID_APPID_CACHE[$pid] ]]; then
        local cached="${PID_APPID_CACHE[$pid]}"
        [[ -n "$cached" ]] && echo "$cached" && return 0 || return 1
    fi

    local found_appid="" walk=$pid
    while [[ "$walk" -ne 1 && -n "$walk" ]]; do
        local owner
        owner=$(stat -c %u /proc/$walk 2>/dev/null)
        [[ -z "$owner" || "$owner" != $(id -u) ]] && break
        local env
        env=$(tr '\0' '\n' < /proc/$walk/environ 2>/dev/null)
        if grep -qE '^(SteamAppId|SteamGameId|STEAM_COMPAT_APP_ID|SteamOverlayGameId)=' <<< "$env"; then
            found_appid=$(grep -E '^SteamAppId=' <<< "$env" | cut -d= -f2)
            break
        fi
        walk=$(awk '/^PPid:/ {print $2}' /proc/$walk/status 2>/dev/null)
    done

    PID_APPID_CACHE[$pid]="$found_appid"
    [[ -n "$found_appid" ]] && echo "$found_appid" && return 0
    return 1
}

maybe_expire_notified() {
    local now appid
    now=$(date +%s)
    for appid in "${!APPID_CLOSE_TIME[@]}"; do
        if (( now - APPID_CLOSE_TIME[$appid] >= RESET_DELAY )); then
            unset "NOTIFIED_APPS[$appid]"
            unset "APPID_CLOSE_TIME[$appid]"
        fi
    done
}

move_if_steam() {
    local addr="$1" pid="$2" clients="$3"

    [[ -z "$pid" || "$pid" == "null" ]] && return

    local appid
    appid=$(get_steam_appid "$pid")
    [[ -z "$appid" ]] && return

    hyprctl dispatch "hl.dsp.window.move({ workspace=$WORKSPACE, window='address:$addr' })" &>/dev/null
    hyprctl dispatch "hl.dsp.window.center({ window='address:$addr' })" &>/dev/null

    unset "APPID_CLOSE_TIME[$appid]"
    ADDR_TO_APPID["$addr"]="$appid"
    APPID_WINDOWS["$appid:$addr"]=1

    if [[ -z "${NOTIFIED_APPS[$appid]}" ]]; then
        NOTIFIED_APPS[$appid]=1
        local title
        title=$(jq -r ".[] | select(.address==\"$addr\") | .title" <<< "$clients")
        [[ -z "$title" || "$title" == "null" ]] && title="Game (PID: $pid)"
        #notify-send -t 5000 "Game Moved" "Moved $title to workspace $WORKSPACE"
        hyprctl notify -1 5000 "rgb(d699b6)" "Moved $title to workspace $WORKSPACE" &>/dev/null
    fi
}

on_close() {
    local addr="$1"
    local appid="${ADDR_TO_APPID[$addr]}"

    [[ -z "$appid" ]] && return

    unset "ADDR_TO_APPID[$addr]"
    unset "APPID_WINDOWS[$appid:$addr]"

    # expiry timer
    local key
    for key in "${!APPID_WINDOWS[@]}"; do
        [[ "$key" == "$appid:"* ]] && return
    done
    APPID_CLOSE_TIME[$appid]=$(date +%s)
}

clients=$(hyprctl clients -j)
while IFS= read -r entry; do
    addr=$(jq -r '.address' <<< "$entry")
    pid=$(jq -r '.pid'     <<< "$entry")
    move_if_steam "$addr" "$pid" "$clients"
done < <(jq -c '.[]' <<< "$clients")

while read -r line; do
    maybe_expire_notified

    if [[ "$line" == openwindow* ]]; then
        [[ "$line" =~ \>\>([a-fA-F0-9]+), ]] || continue
        addr="0x${BASH_REMATCH[1]}"
        clients=$(hyprctl clients -j 2>/dev/null)
        pid=$(jq -r ".[] | select(.address==\"$addr\") | .pid" <<< "$clients")
        move_if_steam "$addr" "$pid" "$clients"

    elif [[ "$line" == closewindow* ]]; then
        [[ "$line" =~ \>\>([a-fA-F0-9]+) ]] || continue
        addr="0x${BASH_REMATCH[1]}"
        on_close "$addr"
    fi
done < <(socat UNIX-CONNECT:"$SOCKET" - 2>/dev/null)
