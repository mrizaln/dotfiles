#!/bin/bash

theme="processtable.rasi"
dir="$HOME/.config/rofi/resource-monitor"
rofi_command="rofi -theme $dir/$theme"

header=("%cpu" "%mem" "cmd")

if [[ "$1" == "cpu" ]]; then
    header[0]="%CPU"
elif [[ "$1" == "mem" ]]; then
    header[1]="%MEM"
fi


python3 $dir/who-monopolize-resource.py $1 | $rofi_command -dmenu  -markup-rows -i -p "  ${header[0]} ${header[1]} ${header[2]}"
