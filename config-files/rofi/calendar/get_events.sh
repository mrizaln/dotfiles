#!/usr/bin/env bash

option=$1
interval=$2

PARENT_DIR="/home/mrizaln/.config/rofi/calendar"
CALENDAR_FILE="${PARENT_DIR}/calendar.ics"
CACHED_CALENDAR_FILE="${PARENT_DIR}/calendar_cache.ics"

script="${PARENT_DIR}/calendar_list.py"
rofi_command="rofi -theme $PARENT_DIR/timetable.rasi -dmenu  -markup-rows -i -p Today"

if ! [[ -e "$CACHED_CALENDAR_FILE" ]]; then
    $script -c -d 30 -f $CALENDAR_FILE      # create cache of 30 days
fi

if [[ $option == "--cache" ]]; then
    $script -c -d $interval -f $CALENDAR_FILE

elif [[ $option == "--print" ]]; then
    event=$($script -p -f $CACHED_CALENDAR_FILE | $rofi_command)

elif [[ $option == "--today" ]]; then
    event=$($script -p -f $CACHED_CALENDAR_FILE --today | $rofi_command)
fi

if [[ $event == "" ]]; then exit 0; fi
zenity --info --text="$event"
