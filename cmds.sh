#!/bin/sh
set -eu

log() {
	echo "$(date) $*" >> /var/log/dwm/dwm_cmds.log
}

disconnect() {
	nohup "$@" > /dev/null 2>&1 &
}

quit_dwm() {
	#printf 'yes\nno\n' | dmenu -f -p "Quit dwm?" | grep -q 'yes' && killall dwm
	action="$(printf 'Lock\nSuspend\nLogout\nShutdown\n' | dmenu -p "Action")"
	log "$(echo "$action" | tr 'A-Z' 'a-z')"
	case "$action" in
		Lock) slock ;;
		Suspend) systemctl suspend && slock ;;
		Logout) killall dwm ;;
		Shutdown) systemctl poweroff ;;
	esac
}

lock_screen() {
	slock
	log "unlocked"
}

mpd_cmd() {
	mpc "$1" > /dev/null
	#sh /etc/dwm/status.sh
}

screenshot() {
	fname="$(date "+%Y%m%d-%H%M")"
	fullname="$HOME/screenshots/screenshot_$fname.png"
	maim -s -m 10 | tee "$fullname" | xclip -selection clipboard -t image/png
}

CMD="${1:-""}"

log "$CMD"
case "$CMD" in
	browser) disconnect firefox ;;
	lock) lock_screen ;;
	screenshot) screenshot ;;
	#terminal) disconnect rxvt-unicode ;;
	terminal) disconnect xfce4-terminal ;;
	password) python3 ~/bin/dmenu-keepassxc.py ;;

	audio_pause) mpd_cmd toggle ;;
	audio_next) mpd_cmd next ;;
	audio_prev) mpd_cmd prev ;;
	audio_info) python3 ~/bin/dmenu-mpd.py -i ;;

	vol_up) pactl set-sink-volume "@DEFAULT_SINK@" "+3%" ;;
	vol_down) pactl set-sink-volume "@DEFAULT_SINK@" "-3%" ;;
	vol_mute) pactl set-sink-mute "@DEFAULT_SINK@" "toggle" ;;

	quit) quit_dwm ;;
esac
