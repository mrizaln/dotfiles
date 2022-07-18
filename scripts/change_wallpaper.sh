#!/bin/env bash

wallpaper_name="current_wallpaper"
wallpaper_path="$HOME/.config"
wall="$wallpaper_path/$wallpaper_name"


pick_random_wallpaper ()
{
    path_random_wallpaper="$HOME/Pictures/Wallpapers"
    if [[ "$1" != "" ]]; then path_random_wallpaper="$1"; fi

    num_files=$(ls ~/Pictures/backgrounds/*{jpg,png} -1 | wc -l)
    wants=$(( 1 + RANDOM % num_files ))                                 # $RANDOM is a feature of bash
    line=0

    while read f; do
        line=$(( line + 1 ))
        file="$f"
        if [[ $line -eq $wants ]]; then
            break
        fi
    done < <(ls "$path_random_wallpaper" | grep -E 'jpg|jpeg|png')
    echo "$path_random_wallpaper/$file"
}


set_wallpaper ()
{
    input="$1"
    output="$2"

    echo $input
    echo $output

    if [[  "$input" == "$output" ]]; then
        exit 0
    fi

    rm "$output"
    cp "$wallpaper_input" "$wall"
    feh --bg-fill "$wallpaper_input"

}


main ()
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
    fi

    # check file path is absolute
    for s in "/" "~"; do
        if [[ $s != ${1:0:1} ]]; then
            absolute=0
        else break
        fi
    done

    # change to absolute path if not absolute path already
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

    set_wallpaper "$1" "$wall"
}


main "$1"
