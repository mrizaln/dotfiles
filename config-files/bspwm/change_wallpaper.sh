#!/bin/bash

if [[ $1 == "" ]]; then
    echo "Usage: ./change_wallpaper.sh </path/to/your/wallpaper>"
    exit 0
fi

absolute=1
for s in "/" "~"; do
    if [[ $s != ${1:0:1} ]]; then
        absolute=0
    else break
    fi
done

if [ $absolute -eq 0 ]; then
    echo please input absolute path to the file
    exit 1
fi

wallpaper_name=current_wallpaper
wallpaper_path=$HOME/.config/bspwm/
wall=$wallpaper_path/$wallpaper_name

rm $wall
ln -s "$1" $wall
feh --bg-fill "$1"

exit 0
