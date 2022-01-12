#!/bin/bash

#while true; do
    used_mem=$(free | grep Mem | tr -s ' ' | cut -d\  -f3)
    total_mem=$(free | grep Mem | tr -s ' ' | cut -d\  -f2)
    percentage=$(( 100 * used_mem / total_mem ))

    if [ $percentage -le 12 ]; then   percentage="▁ $percentage%"
    elif [ $percentage -le 25 ]; then percentage="▂ $percentage%"
    elif [ $percentage -le 37 ]; then percentage="▃ $percentage%"
    elif [ $percentage -le 50 ]; then percentage="▄ $percentage%"
    elif [ $percentage -le 62 ]; then percentage="▅ $percentage%"
    elif [ $percentage -le 75 ]; then percentage="▆ $percentage%"
    elif [ $percentage -le 87 ]; then percentage="▇ $percentage%"
    else                              percentage="█ $percentage%"
    fi

    echo $percentage

#    sleep 1s
#done
