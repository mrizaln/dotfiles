#!/bin/bash

MANY_LINES=5

header=$(ps -eo pcpu,pmem,comm | head -1)
theme="processtable.rasi"
dir="$HOME/.config/rofi/resource-monitor"
rofi_command="rofi -theme $dir/$theme"

add_lines()
{
    col_0=($1)
    col_1=($2)
    cpu_0="${col_0[0]}"
    mem_0="${col_0[1]}"
    cpu_1="${col_1[0]}"
    mem_1="${col_1[1]}"
    name="${col_0[2]}"

    cpu=$(echo "$cpu_0+$cpu_1" | bc)
    mem=$(echo "$mem_0+$mem_1" | bc)

    echo "$cpu $mem $name"
}

get_list()
{
    choice="$1"
    if [ "$choice" == "cpu" ]; then col=1
    elif [ "$choice" == "mem" ]; then col=2
    else col=1
    fi

    count=0
    while read line; do
        line=($line)
        echo ${line[2]}

#        if [ $count -eq 0 ]; then
#            past_line=$line
#            count=1
#            continue
#        fi

        if [[ "${line[2]}" == "${past_line[2]}" ]]; then
            past_line=($(add_lines "$line" "$past_line"))
            echo $past_line
        else
            past_line=$line
            count=$((count + 1))
        fi

        printf "%5s %5s" "${past_line[0]}" "${past_line[1]}"
        echo "  ${past_line[@]:2}"

        if [ $count -gt $MANY_LINES ]; then
            break
        fi
    done < <(ps -eo pcpu,pmem,comm | tail +1 | sort -hrk $col)
}


#a=($(add_lines "3.1 0.2 haha" "5.3 9.1 haha"))
#echo ${a[@]}
#exit 0

header="   ${header// /  }"
get_list $1 ; exit 0;
get_list $1 | $rofi_command -dmenu  -markup-rows -i -p "$header"
