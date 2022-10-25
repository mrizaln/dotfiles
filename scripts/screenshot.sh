#!/usr/bin/env bash

# parse args
option="$1"
copy="$2"
delay=$([[ $3 =~ ^[0-9]+$ ]] && echo $3 || echo 0)      # receive numerical only, if not (or empty) delay = 0

format="png"
name="Screenshot_$(date +%F_%H-%M-%S)"
dir="/home/mrizaln/Pictures/Screenshots"

filename="${dir}/${name}.${format}"

sleep $delay

if   [[ "$option" == "whole" && "$copy" == "copy-only" ]]; then
    import -window root -display :0.0 "${format}:-" | xclip -sel clip -target "image/${format}"
    notify-send "Screenshot copied to clipboard"

elif [[ "$option" == "whole" && "$copy" == "copy" ]]; then
    import -window root -display :0.0 "${filename}"
    xclip -sel clip -target "image/${format}" < "$filename"
    notify-send "Screenshot saved and copied to clipboard"

elif [[ "$option" == "whole" && "$copy" == "no-copy" ]]; then
    import -window root -display :0.0 "${filename}"
    notify-send "Screenshot saved"

elif [[ "$option" == "part" && "$copy" == "copy-only" ]]; then
    import "${format}:-" | xclip -sel clip -target "image/${format}"
    notify-send "Screenshot copied to clipboard"

elif [[ "$option" == "part" && "$copy" == "copy" ]]; then
    import "${filename}"
    xclip -sel clip -target "image/${format}" < "$filename"
    notify-send "Screenshot saved and copied to clipboard"

elif [[ "$option" == "part" && "$copy" == "no-copy" ]]; then
    import "${filename}"
    notify-send "Screenshot saved"

else
    echo -e "not enough argument specified\n"
    echo -e "usage: \t $0  (whole|part)  (copy-only|copy|no-copy)  [delay in seconds]\n"
    exit 0
fi

