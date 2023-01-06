#!/usr/bin/env bash

BUILT_IN_HEIGHT=768
BUILT_IN_WIDTH=1366

run_vnc ()
{
    width=$1
    height=$2
    offset=$3

    echo -e "\nstarting vnc at ${width}x${height}${offset}"

    x11vnc -clip "${width}x${height}${offset}" -repeat -passwd password #-unixpw #-vencrypt nodh:only -ssl
}

run_vnc BUILT_IN_WIDTH BUILT_IN_HEIGHT
