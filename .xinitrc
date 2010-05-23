#!/bin/sh

#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
#

#source /etc/X11/Xsession 2> /tmp/startx.log

xmodmap .Xmodmap

# start ttytter inside screen but only if it's not already running
/mnt/documents/Script/ttytter_screen_startup.sh
#screen -dm -c ~/.screenrc-ttytter &

exec awesome
#exec openbox-session
#exec startkde
# exec gnome-session
#exec /mnt/documents/Script/awesome_autostart.sh
#exec /mnt/documents/Script/dwm_start.sh
#exec /mnt/documents/Script/xmonad_start.sh
