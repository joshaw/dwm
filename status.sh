#!/bin/sh
set -eu

MPD_STATUS=''
if mpc > /dev/null 2>&1; then
	MPD_STATUS="$(mpc status | awk '
		NR==1 { song_name = $0 }
		NR==2 {
			status = ""
			if ($1 == "[playing]")
				status = ">"
			else if ($1 == "[paused]")
				status = "||"

			printf("%s %s %s %s", status, song_name, $4, $2)
		}
	')"
fi

STATUS=" $MPD_STATUS  │  $(date "+%a %d %b %I:%M") "

xsetroot -name "$STATUS"
