#!/bin/sh

#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
#

#source /etc/X11/Xsession 2> /tmp/startx.log

xmodmap .Xmodmap

# start ttytter inside screen but only if it's not already running
#/mnt/documents/Script/ttytter_startup.sh

#exec /mnt/documents/Pacchetti/repos/mstatusbar/monsterbar.sh
exec awesome
#exec openbox-session
#exec startkde
#exec gnome-session
#exec /mnt/documents/Script/dwm_start.sh
#exec /mnt/documents/Script/xmonad_start.sh
