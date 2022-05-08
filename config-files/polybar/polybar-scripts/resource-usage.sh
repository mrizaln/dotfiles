#!/bin/env bash

delta_time=1

color0="#A3BE8C"    #green
color1="#EBCB8B"    #yellow
color2="#FF6A6A"    #red

read_cpu()
{
    cpu_now_0=($(head -n1 /proc/stat))      # read cpu statistics
    cpu_sum_0="${cpu_now_0[@]:1}"
    cpu_sum_0=$((${cpu_sum_0// /+}))        # calculate sum

    sleep $delta_time     # repeat

    cpu_now_1=($(head -n1 /proc/stat))
    cpu_sum_1="${cpu_now_1[@]:1}"
    cpu_sum_1=$((${cpu_sum_1// /+}))

    cpu_delta=$(( cpu_sum_1 - cpu_sum_0 ))          # calculate delta
    cpu_idle=$(( cpu_now_1[4] - cpu_now_0[4] ))
    cpu_used=$(( cpu_delta - cpu_idle ))
    cpu_usage=$(( 100 * cpu_used / cpu_delta ))
    echo "$cpu_usage"
}

read_mem()
{
    mem_now=($(free | grep Mem))
    mem_total="${mem_now[1]}"
    mem_used="${mem_now[2]}"
    mem_usage=$(( 100 * mem_used / mem_total ))
    echo "$mem_usage"
}

read_swap()
{
    swap_now=($(free | grep Swap))
    swap_total="${swap_now[1]}"
    swap_used="${swap_now[2]}"
    swap_usage=$(( 100 * swap_used / swap_total ))
    echo "$swap_usage"
}

format()
{
    percentage="$1"
    if [[ "$2" == "" ]]; then             # if 2nd argument is non-existent, use 1st argument and add percent behind it
        string=$(printf "%02d" "$1")%
    else
        string="$2"
    fi

    if [ "$percentage" -lt 25 ]; then color="$color0"
    elif [ "$percentage" -lt 80 ]; then color="$color1"
    else color="$color2"
    fi
    echo %{F${color}}$string%{F-}
}


cpu="$(read_cpu)"
mem="$(read_mem)"
swap="$(read_swap)"

P=$(format "$cpu" 'P')
M=$(format "$mem" 'M')
S=$(format "$swap" 'S')

cpu=$(format "$cpu")
mem=$(format "$mem")
swap=$(format "$swap")

# echo "[${P}:${cpu}|${M}:${mem}]"
echo "[${P}:${cpu}|${M}:${mem}|${S}:${swap}]"
