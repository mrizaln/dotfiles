#!/bin/bash

wifi_name="$1"
pass_word="$2"
hidden="$3"
device="wlp2s0"
device_status=$(nmcli device status | grep "$device" | tr -s ' '  | cut -d ' ' -f3)

case "$device_status" in
    'connected') nmcli device disconnect "$device";;
    'disconnected') ;;
    *) echo "$device" device "$device_status"; exit 1;;
esac

case "$wifi_name" in
    '') read -p "enter SSID: " wifi_name;;
    *) ;;
esac
case "$pass_word" in
    '') read -s -p "enter password: " pass_word;;
    '-') nmcli device wifi connect "$wifi_name"; exit 0;;
    *) ;;
esac
case "$hidden" in
    'hidden') hidden="yes";;
    *) hidden="no";;
esac

nmcli device wifi connect "$wifi_name" password "$pass_word" hidden "$hidden"
