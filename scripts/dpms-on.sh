#!/usr/bin/env bash
# Turn on DPMS for Hyprland session (useful when clightd turns off the screen via DDC/CI)
# Can be run from a separate TTY

instance=$(ls /run/user/$(id -u)/hypr/ 2>/dev/null | head -1)

if [ -z "$instance" ]; then
    echo "No Hyprland instance found"
    exit 1
fi

HYPRLAND_INSTANCE_SIGNATURE="$instance" hyprctl dispatch dpms on
