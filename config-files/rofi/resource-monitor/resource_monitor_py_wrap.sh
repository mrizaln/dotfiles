#!/bin/env bash

theme="processtable.rasi"
dir="$HOME/.config/rofi/resource-monitor"
rofi_command="rofi -theme $dir/$theme"

header=("%cpu" "%mem |  mem | swap" "processName")

if [[ "$1" == "cpu" ]]; then
    header[0]="%CPU"
elif [[ "$1" == "mem" ]]; then
    header[1]="%MEM |  MEM | swap"
elif [[ "$1" == "swap" ]]; then
    header[1]="%mem |  mem | SWAP"
fi


python3 $dir/resource_monitor.py $1 -n $2 | $rofi_command -dmenu  -markup-rows -i -p " No. |  ${header[0]} | ${header[1]} | ${header[2]}"
