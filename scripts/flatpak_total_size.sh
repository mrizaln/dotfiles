#!/bin/bash

total_size=0
while read size; do
    unit="${size: -2}"
    size=${size:0:-3}
    if [[ "$unit" == "kB" ]]; then
        size=$(echo "$size/1024" | bc -l)
    fi
    total_size=$(echo "${total_size}+${size}" | bc -l)
done < <(flatpak list --columns=size | tail -n+1)

flatpak list --columns=name,size

echo --------------------------------------------------------
# echo -e "\033[1mTotal size:\t\t${total_size:0:8} MB\033[0m"
printf "\033[1mTotal size:\t\t\t%.2f MB\033[0m\n" $total_size
