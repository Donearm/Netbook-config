#!/bin/sh

#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
#

#source /etc/X11/Xsession 2> /tmp/startx.log

# not needed since Xorg 7.4
#xmodmap .Xmodmap



#exec awesome
#exec openbox-session
exec startkde
# exec gnome-session
#exec /mnt/documents/Script/awesome_autostart.sh
#exec /mnt/documents/Script/dwm_start.sh
#exec /mnt/documents/Script/xmonad_start.sh
