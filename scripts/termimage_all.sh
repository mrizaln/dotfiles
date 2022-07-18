#!/bin/bash

clear

for arg in ${@}; do
    if [[ "$arg" == "-t" ]]; then
        timee="-t"
    fi
    if [[ "$arg" == "-r" ]]; then
        reverse="-r"
    fi
    if [[ "$arg" == "-c" ]]; then
        do_clear=true
    fi
done

while read -u 10 f; do                  # 10 is an arbitrary integer used as a file descriptor, u can change it any time
    [[ $do_clear == true ]] && clear
    catimg -w "$((COLUMNS*2))" "$f"         # $COLUMNS is a feature of bash that returns the width of terminal in use
    echo "$f"
    read dummy
done 10< <(ls $timee $reverse | grep -iE "png|jpg|jpeg|webp")
