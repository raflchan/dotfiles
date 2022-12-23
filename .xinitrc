#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

export PATH=${PATH}:$HOME/.local/share/flatpak/exports/bin
nvidia-settings -a 0/AllowFlipping=0
xsetroot -cursor_name left_ptr
xrdb -merge ~/.Xresources
setxkbmap 'de(us)'
xinput set-prop 'pointer:Logitech G502' 'libinput Accel Speed' -0.68
# xrandr --output DP-0 --primary --mode 1920x1080 --rate 144.00 --output HDMI-0 --mode 1920x1080 --rate 60.00 --right-of DP-0

# set resolution properly
xrandr -d :0 --fb 4960x1440 \
    --output DP-0 --mode 2560x1440 --rate 144.00 \
    --scale 1x1 --pos 0x0 \
    --primary \
    \
    --output HDMI-0 --mode 1920x1080 --rate 60.00 \
    --scale 1.25x1.25  \
    --right-of DP-0

exec /usr/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
#exec /usr/bin/i3
