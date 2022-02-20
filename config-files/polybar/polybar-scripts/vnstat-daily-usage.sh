#!/bin/bash

echo > vnstat_daily_usage.data

while read usage; do
    unit="${usage: -3}"
    usage="${usage:0: -3}"

    if [[ "$unit" == "GiB" ]]; then
        usage="$(echo ${usage}*1024 | bc)"
        unit="MiB"
    fi

    echo "$usage" >> vnstat_daily_usage.data

done < <(vnstat -d | awk -F '|' '{print $3}' | tail +6 | head -n -2)

gnuplot -p -e 'set style histogram; plot "vnstat_daily_usage.data" with lines'
rm vnstat_daily_usage.data
