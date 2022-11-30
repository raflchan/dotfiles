#!/bin/bash
poly_pids=$(ps --user $(id -u) | grep -w "polybar" | awk '{$1=$1};1' | cut -d' ' -f1)

while read -r poly_pid; do
    monitor=$(cat "/proc/$poly_pid/environ" | tr '\0' '\n' | grep -w "MONITOR" | cut -d'=' -f2)
    if [ "$monitor" = "$1" ]; then
        echo "$poly_pid"
    fi
done <<< "$poly_pids"
