#!/bin/bash

limit=$1
reg="^[0-9]+$"

if [[ $limit == "" ]]; then echo "please input an argument"; exit 1; fi
if [[ ! $limit =~ $reg ]]; then echo "script can only take numbers as argument"; exit 1; fi

#string="the quick brown fox jumps over the lazy dog"
string=$(timeout 1s /home/mrizaln/.config/polybar/polybar-scripts/player-mpris-tail.py -f ' {title} ')
string_length=${#string}
in_pos=0

while true; do
    new_string=$(timeout 1s /home/mrizaln/.config/polybar/polybar-scripts/player-mpris-tail.py -f ' {title} ')

    if [[ ! "$string" == "$new_string" ]]; then
        string="$new_string"
        string_length=${#string}
        in_pos=0
    fi

    fi_pos=$(( string_length - 2 ))

    if [ $fi_pos -lt 0 ]; then continue; fi

    if [[ $in_pos -gt $(( string_length + 2 )) ]]; then in_pos=1; fi

    mod_string="${string:$in_pos:$fi_pos}${string:0:$in_pos}"

    echo "[${mod_string:0:$limit} ]"

    in_pos=$(( in_pos + 1 ))

done
