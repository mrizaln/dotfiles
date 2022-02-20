    #!/bin/bash

color0="#A3BE8C"    #green
color1="#EBCB8B"    #yellow
color2="#BF616A"    #red

color="$color0"

#while true; do
    used_mem=$(free | grep Mem | tr -s ' ' | cut -d\  -f3)
    total_mem=$(free | grep Mem | tr -s ' ' | cut -d\  -f2)
    percentage=$(( 100 * used_mem / total_mem ))

    if [ $percentage -le 12 ]; then
        percentage="▁ $percentage%"
        color="$color0"
    elif [ $percentage -le 25 ]; then
        percentage="▂ $percentage%"
        color="$color0"
    elif [ $percentage -le 37 ]; then
        percentage="▃ $percentage%"
        color="$color0"
    elif [ $percentage -le 50 ]; then
        percentage="▄ $percentage%"
        color="$color1"
    elif [ $percentage -le 62 ]; then
        percentage="▅ $percentage%"
        color="$color1"
    elif [ $percentage -le 75 ]; then
        percentage="▆ $percentage%"
        color="$color1"
    elif [ $percentage -le 87 ]; then
        percentage="▇ $percentage%"
        color="$color2"
    else
        percentage="█ $percentage%"
        color="$color2"
    fi

    echo %{F${color}}$percentage%{F-}
