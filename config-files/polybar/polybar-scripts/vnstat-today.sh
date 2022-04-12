#!/bin/env bash

color="#EBCB8B"     #yellow

usage=$(vnstat | grep today | cut -d/ -f3 | tr -s ' ' | cut -d\  -f2-)
echo "[%{F$color}${usage%% }%{F-}]"
