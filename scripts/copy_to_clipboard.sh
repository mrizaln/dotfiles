#!/bin/bash

if [[ -p /dev/stdin ]]; then
    stdin_data=$(cat)        # read stdin
fi

target=$(file -b --mime-type "$1")
file="$1"
content="$2"

# copy content of a text file
copy_content()
{
    file="$1"
    target_type="$2"
    cat "$file" | xclip -r -sel clip

    echo "$target_type"
    echo "$file"
    notify-send "Copied contents of  '$file'  to clipboard"
}

### workaround for jpeg
copy_jpeg()
{
    file="$1"
    target_type="$2"

    temp_file="/tmp/$(date +%F_%H-%M-%S).png"
    convert "$file" "$temp_file"        # convert jpeg file into png file in /tmp
    target="image/png"

    xclip -sel clip -target "$target_type" < "$file"

    echo "$target_type"
    echo "$file"
    notify-send "Copied  '$file'  to clipboard"

    rm "$temp_file"                                  # remove the converted jpeg file
}


if [[ "$1" == "" ]]; then
    echo "usage: $0 <file> [content]"
elif [[ "$1" == "-" ]]; then
    echo "$stdin_data" | xclip -sel clip -target "text/plain"
elif [[ ! ("$content" == "") && (("$target" == "text/plain") || ("$target" =~ "text/x-")) ]]; then
    copy_content "$file" "$target"
elif [[ ("$target" == "image/jpeg") || ("$target" == "image/jpg") ]]; then
    copy_jepg "$file" "$target"
else
    # do normally
    xclip -sel clip -target "$target" < "$file"

    echo "$target"
    echo "$file"
    notify-send "Copied  '$file'  to clipboard"
fi

