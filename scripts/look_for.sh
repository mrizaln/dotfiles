#!/usr/bin/env bash

draw_line()
{
    num=$1
    char=$2

    i=0
    while [[ $i -lt $1 ]]; do
        echo -n "$2"
        i=$((i+1))
    done
    echo ""
}

print_color()
{
    color="\033[0;30;42m"      # ANSI escape codes for green
    reset="\033[0m"       #                       no color

    echo -e "${color}${1}${reset}"
}

print_bold()
{
    bold="\033[1;3m"
    reset="\033[0m"

    echo -e "${bold}${1}${reset}"
}


phrase="$1"
if [[ "$phrase" == "" ]]; then
    echo "Usage: $0 <phrase> [file extension]"
    echo "exited with status 0"
    exit 0
fi

extension="$2"

while read f; do
    lines=$(GREP_COLORS="ms=1;31;45" grep --color=always -C3 -iEe "$phrase" "$f")

    # if lines is empty, skip
    if [[ "$lines" == "" ]]; then
        continue
    fi

    draw_line $(tput cols) "="          # separator

    # file name
    print_color "file: [ $(print_bold "$f") ]"
    draw_line $((${#f} + 10 )) "-"
    echo

    # grep-ed lines
    echo -e "$lines"

    draw_line $(tput cols) "#"          # separator
    echo -e "\n\n\n"
done < \
    <(find . -type f | grep -iEe "${extension}$") \
    | less -R
