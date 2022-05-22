#!/bin/bash

if [[ "$1" == "" ]]; then
    echo "usage: $0 <file> [content]"
    exit 0
fi

target=$(file -b --mime-type "$1")
file="$1"
content="$2"

if [[ ! ("$content" == "") && (("$target" == "text/plain") || ("$target" == "text/x-shellscript")) ]]; then
    cat "$1" | xclip -r -sel clip

    echo "$target"
    echo "$file"
    notify-send "Copied contents of  '$file'  to clipboard"

    exit 0
fi

### workaround for jpeg
if [[ ("$target" == "image/jpeg") || ("$target" == "image/jpg") ]]; then
    temp_file="/tmp/$(date +%F_%H-%M-%S).png"
    convert "$file" "$temp_file"        # convert jpeg file into png file in /tmp
    target="image/png"

    xclip -sel clip -target "$target" < "$file"

    echo "$target"
    echo "$file"
    notify-send "Copied  '$file'  to clipboard"

    rm "$temp_file"                                  # remove the converted jpeg file
    exit 0
fi
### end of workaround

xclip -sel clip -target "$target" < "$file"

echo "$target"
echo "$file"
notify-send "Copied  '$file'  to clipboard"

exit 0
