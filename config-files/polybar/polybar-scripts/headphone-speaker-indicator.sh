#!/usr/bin/env bash

port="$(pactl list sinks | grep "Active" | cut -d: -f2 | cut -d- -f3)"

case "$port" in
    "headphones")
        echo H
        ;;
    "speaker")
        echo S
        ;;
esac
