#!/bin/env bash

theme="processtable.rasi"
dir="$HOME/.config/rofi/resource-monitor"
rofi_command="rofi -theme $dir/$theme"

header=("%cpu" "%mem|bytes" "processName")

if [[ "$1" == "cpu" ]]; then
    header[0]="%CPU"
elif [[ "$1" == "mem" ]]; then
    header[1]="%MEM|BYTES"
fi


python3 $dir/who_monopolize_resource.py $1 | $rofi_command -dmenu  -markup-rows -i -p "   ${header[0]}  ${header[1]}   ${header[2]}"
