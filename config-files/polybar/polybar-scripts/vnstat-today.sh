#!/bin/env bash

color="#EBCB8B"     #yellow
interface=wlp2s0

usage=$(vnstat -i $interface | grep today | cut -d\| -f3 | tr -s ' ' | cut -d\  -f2-)
echo "[%{F$color}${usage%% }%{F-}]"
