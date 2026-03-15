#!/usr/bin/env zsh

current=$(brightnessctl -d intel_backlight g)
max=$(brightnessctl -d intel_backlight m)

percent=$(( current * 100 / max ))

if (( percent > 5 )); then
    brightnessctl -d intel_backlight set 5%-
fi
