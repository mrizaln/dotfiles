#!/usr/bin/env bash

currenttime="$(date +%s)"
todaydate="$(date +%D)"

# Events are placed in $calendarfile.
# The lines of this file are written in the following format.
#
#       event time, title, description, google meet code (or additional info)
#
# The description, google meet code are optional. Note that 'event time'
# must be in a valid 'date --date=' string format. For example, '14:30'
# (2:30 pm on the current day), '12:15 Wed' (12:15 pm every Wednesday -
# useful for daily timetables), or '16:45 January 11 2020' are valid.
# The file may contain comments (#) and empty lines.

theme="timetable.rasi"
dir="$HOME/.config/rofi/timetable"
rofi_command="rofi -theme $dir/$theme"
calendarfile="$HOME/.config/calendar"           # calendar event file

strip_excess() {
        sed 's/^\s*#.*$//g' | sed '/^$/d' | sed 's/\s*,\s*/,/g'
}

format_entries() {
        IFS=,
        cat "$calendarfile" | strip_excess | while read line; do
                read etime title link<<< $line
                eventdate="$(date --date=$etime +%D)"

                [[ "$eventdate" != "$todaydate" ]] && continue

                eventtime="$(date --date=$etime +%s)"
                eventtime=$(( eventtime + 1800))        # add 30 minutes of delay
                hhmm="$(date --date=$etime +%H:%M)"

                if [[ $eventtime -lt $currenttime ]]; then
                        printf "<span color=\"#777777\">%-16s %-66s %16s</span>\n" "$hhmm" "$title" "$link"
#                        printf "<span color=\"#444444\">%6s  %-16s  %-46s %16s</span>\n" "$hhmm" "$title" "$link"
                else
                        printf "%-16s %-66s <span color=\"#777777\">%16s</span>\n" "$hhmm" "$title" "$link"
#                        printf "%6s  %-16s  <span color=\"#777777\">%-46s</span> %16s\n" "$hhmm" "$title" "$link"
                fi
        done
}

get_code() {
        format_entries \
                | sort \
                | $rofi_command -dmenu  -markup-rows -i -p 'Today' \
                | sed 's/<[^>]*>//g' \
                | sed 's/^.* //g'
}

the_link="$(get_code)"
if [[ ! -z "$the_link" ]]; then
#        firefox "$the_link"
        container_name="Work/School"
        firefox "ext+container:name=${container_name}&url=${the_link}"          # need this extension to work: https://addons.mozilla.org/en-US/firefox/addon/open-url-in-container/
        echo "$the_link"
fi
