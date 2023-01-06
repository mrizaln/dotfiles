#!/bin/bash

selected=$(cat .config/calendar | grep -v '#'| tail -n+4 |awk -F ',' '{print $1 $2}' | rofi -dmenu -i -p '')
if [[ "$(echo $selected | tr -s ' ')" == '' ]]; then exit 0; fi

# Open corresponding meeting room, if exists
#selected=$(echo "$selected | cut -d\  -f-2")
#link="https://$(grep "$selected" .config/calendar | cut -d '/' -f3-)"
#if [[ "$link" == 'https://' ]]; then exit 0; fi
#container_name="Work/School"
#firefox "ext+container:name=${container_name}&url=${link}"          # need this extension to work: https://addons.mozilla.org/en-US/firefox/addon/open-url-in-container/

# Open corresponding directory
dirname=$(echo "$selected" | tr -s ' ' | cut -d\  -f3-)

tri_last="${selected:(( ${#selected} - 3 )):3}"
if [[ "${tri_last:0:1}" == "(" ]]; then
    kuliah_type="${tri_last:1:1}"
    dirname="${dirname:0:-4}"
fi

parent_dir="/home/mrizaln/Documents/Perkuliahan/Kelas/Semester 6"
thunar "${parent_dir}/${dirname}" 2> /dev/null &
