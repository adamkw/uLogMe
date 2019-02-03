#!/bin/bash
# logdesktop.sh for https://github.com/Naereen/uLogMe/
# MIT Licensed, https://lbesson.mit-license.org/
#
# periodically takes screenshot and saves them to desktopscr/
# the filename contains unix time

# Use https://bitbucket.org/lbesson/bin/src/master/.color.sh to add colors in Bash scripts
[ -f color.sh ] && . color.sh

# wait time in seconds
waittime="900"
# directory to save screenshots to
saveprefix="../desktopscr/scr"
mkdir -p ../desktopscr

#------------------------------

while true
do
	islocked=true
	# Try to figure out which Desktop Manager is running and set the
	# screensaver commands accordingly.
	if [[ X"$GDMSESSION" == X'xfce' ]]; then
		# Assume XFCE folks use xscreensaver (the default).
		screensaverstate=$(xscreensaver-command -time | cut -f2 -d: | cut -f2-3 -d' ')
		if [[ $screensaverstate =~ "screen non-blanked" ]]; then
			islocked=false
		fi
	elif [[ X"$GDMSESSION" == X'ubuntu' || X"$GDMSESSION" == X'ubuntu-2d' || X"$GDMSESSION" == X'gnome-shell' || X"$GDMSESSION" == X'gnome-classic' || X"$GDMSESSION" == X'gnome-fallback' ]]; then
		# Assume the GNOME/Ubuntu folks are using gnome-screensaver.
		screensaverstate=$(gnome-screensaver-command -q 2>&1 /dev/null)
		if [[ $screensaverstate =~ .*inactive.* ]]; then
			islocked=false
		fi
    elif [[ X"$GDMSESSION" == X'cinnamon' ]]; then
		screensaverstate=$(cinnamon-screensaver-command -q 2> /dev/null)
		if [[ $screensaverstate =~ .*inactive.* ]]; then
			islocked=false
		fi
	elif [[ X"$XDG_SESSION_DESKTOP" == X'KDE' ]]; then
		islocked=$(qdbus org.kde.screensaver /ScreenSaver org.freedesktop.ScreenSaver.GetActive)
	else
		# If we can't find the screensaver, assume it's missing.
		islocked=false
	fi

	if ! $islocked
	then
		# take screenshot into file
		#T="$(date +%s)"
        T="$(date +'%Y-%m-%d_%H-%M-%S')"
		fname="${saveprefix}_${T}.jpg"
		# q is quality. Higher is higher quality
		scrot -q 1 --thumb 10 "$fname"
	else
		echo -e "${red}Screen is locked, waiting ...${reset}"
	fi

	sleep "$waittime"
done
