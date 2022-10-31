#!/bin/sh

driver=$(lspci -k | grep -A 2 -E "(VGA|3D)" | grep "Kernel modules: " | tr -d '\t' | sed -e 's/^Kernel modules: //')
echo "detected '$driver' as driver"

case $driver in
    "vmwgfx")
        echo "falling back to xrender backend"
        picom --backend xrender
        exit
        ;;
    *)
        picom --backend glx --experimental-backend --blur-method dual_kawase
        exit
        ;;
esac

