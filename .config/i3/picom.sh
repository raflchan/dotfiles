#!/bin/sh

driver=$(lspci -k | grep -A 2 -E "(VGA|3D)" | grep "Kernel modules: " | tr -d '\t' | sed -e 's/^Kernel modules: //')
vendor=$(glxinfo | grep  "OpenGL vendor string:" | sed -e "s/^OpenGL vendor string: //g")
echo "detected '$driver' as driver"
echo "detected '$vendor' as vendor"

case $vendor in
    "Mesa/X.org")
        echo "falling back to xrender backend"
        picom --backend xrender
        exit
        ;;
    *)
        picom --backend glx --experimental-backend --blur-method dual_kawase
        exit
        ;;
esac
