#!/bin/bash

is_floating=$(hyprctl activewindow | awk -F": " '/floating:/ {print $2}')

if [[ $is_floating == "1" ]]; then
    hyprctl dispatch togglefloating
    exit 0
fi

hyprctl dispatch togglefloating
hyprctl dispatch resizeactive exact 50% 50%
hyprctl dispatch centerwindow
