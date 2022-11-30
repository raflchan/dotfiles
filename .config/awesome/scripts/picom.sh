#!/bin/sh

#not handling multiple picom instances yet
RUNNING_PICOM=$(cat /proc/$(ps --user $(id -u) | grep picom | awk '{$1=$1};1' | cut -d' ' -f1)/environ | tr '\0' '\n' | grep DISPLAY | cut -d'=' -f2)

if [ "$DISPLAY" = "$RUNNING_PICOM" ]; then
    pkill -15 picom
    echo 'cool' > "$HOME/cool.txt"
fi

pkill -x -15 picom

#driver=$(lspci -k | grep -A 2 -E "(VGA|3D)" | grep "Kernel modules: " | tr -d '\t' | sed -e 's/^Kernel modules: //')
vendor=$(glxinfo | grep  "OpenGL vendor string:" | sed -e "s/^OpenGL vendor string: //g")
#echo "detected '$driver' as driver"
echo "[picom.sh] detected '$vendor' as vendor"

case $vendor in
    "Mesa/X.org")
        echo "[picom.sh] falling back to xrender backend"
        picom --backend xrender &
        exit
        ;;
    *)
        echo "[picom.sh] using glx backend with dual_kawase blur"
        picom --backend glx --blur-method dual_kawase &
        exit
        ;;
esac
