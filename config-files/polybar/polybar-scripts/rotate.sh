#!/bin/bash

limit=20
in_pos=0

read string

while true; do
#    if [[ "$new_string" != "" ]] || [[ "$string" != "$new_string" ]]; then
#        string="$new_string"
#    fi
#    read string
    echo $string

    string_length=${#string}
    fi_pos=$(( string_length - 2 ))

    if [ $fi_pos -lt 0 ]; then continue; fi

    if [[ $in_pos -gt $(( string_length + 2 )) ]]; then
        in_pos=1
    fi

    mod_string="${string:$in_pos:$fi_pos}${string:0:$in_pos}"
    echo "[${mod_string:0:$limit}]"

    in_pos=$(( in_pos + 1 ))

    sleep 1
done < <($PWD/player-mpris-tail.py)
