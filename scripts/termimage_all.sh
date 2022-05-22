#!/bin/bash

clear

for arg in ${@}; do
    if [[ $arg =~ ^\-w.* ]]; then
        width="-w  ${arg#"-w="}"
    fi
    if [[ "$arg" = "-t" ]]; then
        timee="-t"
    fi
    if [[ "$arg" = "-r" ]]; then
        reverse="-r"
    fi
done

while read -u 10 f; do                  # 10 is an arbitrary integer used as a file descriptor, u can change it any time
    catimg "$width" "$f"
    echo "$f"
    read dummy
done 10< <(ls $timee $reverse | grep -iE "png|jpg|jpeg|webp")
