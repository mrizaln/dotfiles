#!/bin/env bash

wallpaper_name="current_wallpaper"
wallpaper_path="$HOME/.config"
wall="$wallpaper_path/$wallpaper_name"


pick_random_wallpaper()
{
    local path_random_wallpaper="$HOME/Pictures/Wallpapers"
    if [[ "$1" != "" ]]; then path_random_wallpaper="$1"; fi

    local num_files=$(ls ~/Pictures/backgrounds/*{jpg,png} -1 | wc -l)
    local wants=$(( 1 + RANDOM % num_files ))                                 # $RANDOM is a feature of bash
    local line=0

    while read f; do
        line=$(( line + 1 ))
        local file="$f"
        if [[ $line -eq $wants ]]; then
            break
        fi
    done < <(ls "$path_random_wallpaper" | grep -E 'jpg|jpeg|png')
    echo "$path_random_wallpaper/$file"
}


set_wallpaper()
{
    local input="$1"
    local output="$2"

    # echo $input
    # echo $output

    if [[  "$input" == "$output" ]]; then
        exit 0
    fi

    rm "$output"
    cp "$input" "$wall"
    feh --bg-fill "$input"
}


main()
{
    # arg parser
    if [[ "$1" == "" ]]; then
        echo "Usage: ./change_wallpaper.sh </path/to/your/wallpaper>"
        exit 0
    elif [[ "$1" == "--original" ]]; then
        feh --bg-fill "$wall"
        exit 0
    elif [[ "$1" == "--default" ]]; then
        feh --bg-fill "$wallpaper_path/default_wallpaper"
        exit 0
    elif [[ "$1" == "--random" ]]; then
        feh --bg-fill "$(pick_random_wallpaper $HOME/Pictures/backgrounds)"
        exit 0
    elif [[ "$1" == "--random-scheme" ]]; then
        local dir="$HOME/Pictures/Illust"
        local files=$(find "$dir" -regex "\.?/.*\.\(jpe?g\|png\)" -type f)
        local files_list
        readarray -t files_list <<< "$files"

        local file
        while true; do
            local idx=$(( 1 + RANDOM % ${#files_list[@]}))      # $RANDOM is a feature of bash
            file="${files_list[idx]}"
            
            local width; local height
            read width height < <(identify -format "%w %h\n" "$file")   # identify resolution
            local threshold_aspect_ratio="1.3"
            if [[ $(echo "$threshold_aspect_ratio < $width/$height" | bc -l) == 1 ]]; then
                break;
            fi
        done
        wal -i "$file" -b "#212733" -a 70 --saturate 0.8 #--backend colorz
        exit 0
    fi

    # check file path is absolute
    for s in "/" "~"; do
        if [[ $s != ${1:0:1} ]]; then
            absolute=0
        else
            absolute=1 
            break
        fi
    done

    # change to absolute path if not absolute path already
    local wallpaper_input
    if [ $absolute -eq 0 ]; then
        wallpaper_input="$PWD/$1"
        echo "$wallpaper_input"
    else
        wallpaper_input="$1"
    fi

    # check file exist
    if [[ ! -f "$1" ]]; then
        echo "File '$1' does not exist"
        echo "Exit"
        exit 1
    fi

    set_wallpaper "$wallpaper_input" "$wall"

    echo "Wallpaper set to $wallpaper_input"
}


main "$1"
