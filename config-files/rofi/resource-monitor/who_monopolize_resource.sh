#!/bin/bash

header=$(ps -eo pcpu,pmem,comm | head -1)
theme="processtable.rasi"
dir="$HOME/.config/rofi/resource-monitor"
rofi_command="rofi -theme $dir/$theme"

get_list()
{
    choice="$1"
    if [ "$choice" == "cpu" ]; then col=1
    elif [ "$choice" == "mem" ]; then col=2
    else col=1
    fi

    while read line; do
        line=($line)
        printf "%5s %5s  %-10s\n" "${line[0]}" "${line[1]}" "${line[2]}"
    done < <(ps -eo pcpu,pmem,comm | tail +1 | sort -hrk $col | head -5)
}

header="   ${header// /  }"
get_list $1; exit 0
#get_list $1 | $rofi_command -dmenu  -markup-rows -i -p "$header"
