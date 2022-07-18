#!/bin/env bash

# no args
if [[ "$1" == "" ]]; then
    echo "usage $0 <type> <target file>"
    exit 1
else
    file_type="$1"
fi

if [[ "$2" == "" ]]; then
    target_file="$(date +%F_%H-%M-%S)"
fi


# check if file path is absolute
for s in "/" "~"; do
    if [[ $s != ${target_file:0:1} ]]; then
        absolute=0
    else break
    fi
done

# change to absolute path if not absolute path already
if [ $absolute -eq 0 ]; then
    target="$PWD/$target_file"
    echo "$target_file"
fi

# check file exist
if [[ -f "$target" ]]; then
    echo "File '$target' already exist"
    echo "Exiting"
    exit 1
fi

# check if the clipboard contain $file_type
contains_specified_type=$(xclip -sel clip -t TARGETS -o | grep "$file_type" | wc -l)
if [[ $contains_specified_type -eq 0 ]]; then
    notify-send "Clipboard does not contain $file_type"
    exit 1
else
    xclip -sel clip -t "$file_type" -o > "$target"
    notify-send "File saved as $target"
fi
