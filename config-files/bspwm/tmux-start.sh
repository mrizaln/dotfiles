#!/usr/bin/env bash

echo "Disk Usage:"
$HOME/.local/bin/check_disk_usage.py
echo -e "\nBasic Information:"
neofetch

echo -e "\nUpdating calendar: (ctrl+c to cancel)"
cal_dir="$HOME/.config/rofi/calendar"
cal_cmd="${cal_dir}/calendar_list.py"
python3 $cal_cmd -c $cal_dir -d 7 -f $cal_dir/calendar.ics

echo -e "\nthis week's schedule: "

python3 $cal_cmd -q -p -f $cal_dir/calendar_cache.ics | awk '{print "\t"$0}'
