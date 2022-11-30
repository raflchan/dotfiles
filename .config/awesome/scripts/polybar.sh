#!/bin/sh

# kill all existing polybars
pkill -15 -x polybar

# get list of displays
displays=$(polybar -m | cut -d':' -f1)
primary=$(polybar -m | grep primary | cut -d':' -f1)

while read -r display; do
    if [ "$display" = "$primary" ]; then
        pos="right"
    else
        pos="none"
    fi
    POLY_TRAY_POSITION="$pos" MONITOR="$display" polybar &
done <<< "$displays"
