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

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

slstatus -d &
xcape -e 'Super_L=Super_L|F1' -d &
albert &
sudo powertop  --auto-tune &
clipit -dn &
feh --bg-fill Pictures/sf.jpg &

eval $(ssh-agent)
ssh-add ~/.ssh/github

# Horizontal scroll
xinput set-prop "AlpsPS/2 ALPS DualPoint TouchPad" "Synaptics Two-Finger Scrolling" 1 1
# Palm detection
xinput set-prop "AlpsPS/2 ALPS DualPoint TouchPad" "Synaptics Palm Detection" 1
# Middle and Second click 
synclient TapButton1=1
synclient TapButton2=3
synclient TapButton3=2

# Caps lock IS OFF
xmodmap -e "keycode 66 ="

# Noop
sudo -- zsh -c 'echo noop >! /sys/block/sda/queue/scheduler'

# TZ
export TZ=:/etc/localtime

exec dwm
