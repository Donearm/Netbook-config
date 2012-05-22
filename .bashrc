alias vi="vim"
alias ls="ls --color=always"
alias ll="ls -asl -F -T 0 -b -H -1 --color=always"
alias less="less -r"
alias cp="cp -p"
alias df="df -T"
alias du="du -h -c"
alias bash="/bin/bash --login"
alias konsole="konsole --ls"
alias startx="startx -- -nolisten tcp -deferglyphs 16 -dpi 96 2> /tmp/startx.log ; exit"
alias fetf="fetchmail -F pop.mail.yahoo.it pop3.live.com" 
alias fetco="fetchmail -c"
alias gmail="mutt -f imaps://forod.g@imap.gmail.com:993"
alias gmail2="mutt -f imaps://fioregianluca@imap.gmail.com:993"
alias bajkal="mutt -f imap://in.virgilio.it"
alias pop3msn="mutt -f pops://kinetic8@live.com@pop3.live.com:995"
alias pop3yahoo="mutt -f pop://gianluca1181@pop.mail.yahoo.it"
alias alsamixer="alsamixer -V all"
alias feh="feh --fontpath /usr/share/fonts/TTF/"
alias chrome="google-chrome -proxy-server=http://127.0.0.1:8118"
alias ntpdate_eur="sudo sntp -s 0.europe.pool.ntp.org"
# two openssl aliases to encode/decode files
alias ssl_dec="openssl aes-256-cbc -d"
alias ssl_enc="openssl aes-256-cbc -salt"
# Skype using gtk instead of qt
alias skype="skype --disable-cleanlooks -style GTK"
# Mplayer using 2 threads/cpu by default 
# disabled because it make playing dvds impossible
#alias mplayer="mplayer -lavdopts fast:threads=2"
# Feh alias for loading all the images in the directory
#alias fehall="feh --scale-down -S filename ."
alias orphans="pacman -Qtdq"
alias svim="sudo vim"
# rsync alias to sync with kortirion over ssh
alias ssrsync="rsync -avz --progress --inplace --delete-after --rsh='ssh -p8898'"
# sync Tiddlywiki
alias tiddlysync="rsync -avz --progress --inplace --delete-after --rsh='ssh -p8898' kortirion:/home/gianluca/.tiddlywiki/ /home/gianluca/.tiddlywiki/"

# top 15 most used commands
topfifteen() {
	history | awk '{print $4}' | awk 'BEGIN {FS ="|"} {print $1}' \
		| grep -v topfifteen | sort | uniq -c | sort -rn | head -15
}

# mkmv - creates a new directory and moves the file into it, in 1 step
# Usage: mkmv <file> <directory>
mkmv() {
    mkdir "$2"
    mv "$1" "$2"
}

startX() {
	nohup &> /dev/null startx -- -nolisten tcp -deferglyphs 16 -dpi 96 2> ~/.xsession-errors
	disown
	logout
}

# Pngtojpeg - converts each png file in the current directory in a jpeg
pngtojpeg() {
	for p in *.[pP][nN][gG] ; do
		convert "$p" "${p%.*}.jpg" ;
	done
}

# No one should read/write/execute my files by default
#umask 0077

# Bash Colors
bblack="\033[0;30m" # black
bred="\033[0;31m" # red
bRed="\033[1;31m" # bold red
bgreen="\033[0;32m" # green
bGreen="\033[1;32m" # bold green
byellow="\033[0;33m" # yellow
bYellow="\033[1;33m" # bold yellow
bblue="\033[0;34m" # blue
bBlue="\033[1;34m" # bold blue
bmagenta="\033[0;35m" # magenta
bMagenta="\033[1;35m" # bold magenta
bcyan="\033[0;36m" # cyan
bCyan="\033[1;36m" # bold cyan
bwhite="\033[0;37m" # white
bnc="\033[0;0m" # no color
# background colors
bgblack="\033[40m"
bgred="\033[41m"
bggreen="\033[42m"
bgyellow="\033[43m"
bgblue="\033[44m"
bgmagenta="\033[45m"
bgcyan="\033[46m"
bgwhite="\033[47m"

#export PATH=/usr/X11R6/bin:/usr/sbin:/sbin/:/usr/local/sbin/:/usr/local/bin:/opt/kde/bin:/usr/lib/python2.5/:/opt/gnome/bin:/lib/splash/bin:/opt/xfce4/bin/:/opt/texlive/bin:$PATH
export PATH=/usr/local/bin:$PATH

# Bash Prompts
if [[ `whoami` == "root" ]]; then
	export PS1=".:\$(date +%d/%m/%Y):. \w \n ${bred} >: ${bnc}"
else
	export PS1=".:\$(date +%d/%m/%Y):. \w \n >: "
fi

export BROWSER="/usr/bin/firefox"
export EDITOR="vim"
export MAIL="$HOME/Maildir/"
export SERVER='news.tin.it'
export SLANG_EDITOR='vim'
export NNTPSERVER='news.tin.it'
export MAILCHECK=600000000000 # I don't really need a shell mailcheck....
export LANG=it_IT.utf8
export LANGUAGE=it_IT.utf8
export LC_TYPE=it_IT.utf8
export LC_CTYPE=it_IT.utf8
export LC_ALL=it_IT.utf8
# use less with utf8
export LESSCHARSET="utf-8"
export DATE=`date +%G_%m_%d`
# set the size of the bash history
export HISTSIZE=5000
# add date and time to history elements
export HISTTIMEFORMAT='%F %T '
export HISTCONTROL=ignoreboth # evita di salvare doppioni in bash_history
# Colorized grep output
export GREP_OPTIONS="--color"

# set ls colors
# di=directories, fi=files, ln=symbolic links, pi=fifo, so=sockets,
# bd=block files, cd=character files, or=symbolic orphaned links,
# mi=non-existent files that have a symbolic link to them,
# ex=executables
#
# Color numbers:
# 0 (default)
# 1 (bold)
# 4 (underlined)
# 5 (flashing)
# 7 (reverse field)
# 31 (red)
# 32 (green)
# 33 (orange)
# 34 (blue)
# 35 (purple)
# 36 (cyan)
# 37 (grey)
# 40 (black background)
# 41 (red background)
# 42 (green background)
# 43 (orange background)
# 44 (blue background)
# 45 (purple background)
# 46 (cyan background)
# 47 (grey background)
# 90 (dark grey)
# 91 (light red)
# 92 (light green)
# 93 (yellow)
# 94 (light blue)
# 95 (light purple)
# 96 (turquoise)
# 100 (dark grey background)
# 101 (light red background)
# 102 (light green background)
# 103 (yellow background)
# 104 (light blue background)
# 105 (light purple background)
# 106 (turquoise background
export LS_COLORS="di=1:fi=0:ln=95:pi=93:so=36:bd=96:cd=96:or=95,101:mi=95,101:ex=94"

# set the desktop integration for OO (may be kde or gnome)
export OOO_FORCE_DESKTOP=gnome
# to improve firefox responsiveness
export MOZ_DISABLE_PANGO=1
# improve intel graphic performance
export INTEL_BATCH=1

# auto completion
source /etc/bash_completion.d/git
source /usr/share/bash-completion/completions/task
# using udisks_functions aliases as udisks wrapper
source /mnt/documents/Script/utilities/udisks_functions

clear # clear the screen if something is on it
