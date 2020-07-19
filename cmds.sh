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
}

screenshot() {
	fname="$(date "+%Y%m%d-%H%M")"
	fullname="$HOME/screenshots/screenshot_$fname.png"
	maim -s -m 10 | tee "$fullname" | xclip -selection clipboard -t image/png
	[ -s "$fullname" ] || rm -f "$fullname"
}

calendar() {
	EXPIRE="$((15 * 1000))"
	HEADER="    $(date '+%a %d %b %Y')"
	BODY="\n$(ncal -bh |
		sed -e '1d' \
			-e 's/^/    /' \
			-e 's/\s*$//' \
			-e 's#\(.....\)$#<i>\1</i>#' \
			-e "s# \($(date "+%d")\) # <u><i><b>\1</b></i></u> #")"
	notify-send -i "none" -t "$EXPIRE" "$HEADER" "$BODY"
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
	calendar) calendar ;;

	audio_pause) mpd_cmd toggle ;;
	audio_next) mpd_cmd next ;;
	audio_prev) mpd_cmd prev ;;
	audio_info) python3 ~/bin/dmenu-mpd.py -i ;;

	vol_up) pactl set-sink-volume "@DEFAULT_SINK@" "+5%" ;;
	vol_down) pactl set-sink-volume "@DEFAULT_SINK@" "-5%" ;;
	vol_mute) pactl set-sink-mute "@DEFAULT_SINK@" "toggle" ;;

	quit) quit_dwm ;;
esac
