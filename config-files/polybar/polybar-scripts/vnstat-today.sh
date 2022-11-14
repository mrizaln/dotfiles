#!/bin/env bash

colors=($(xrdb -query | sed -n 's/.*color\([0-9]\)/\1/p' | sort -nu | cut -f2))

color="${colors[3]}"     #yellow
interface=wlp2s0

usage=$(vnstat -i $interface | grep today | cut -d\| -f3 | tr -s ' ' | cut -d\  -f2-)
echo "[%{F$color}${usage%% }%{F-}]"
