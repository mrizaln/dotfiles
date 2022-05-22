#!/bin/bash

case $1 in
    '')
    echo 'shutdown/restart/suspend?'
    read inp
    ;;

    *)
    inp=${1#"-"}
    ;;
esac

case $inp in
    'u')
    shutdown -P now
    ;;

    'r')
    systemctl reboot -i
    ;;

    's')
    systemctl suspend -i
    ;;
esac
