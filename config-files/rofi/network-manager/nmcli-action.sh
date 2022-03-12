#!/bin/bash

device="wlp2s0"

theme="networktable.rasi"
dir="$HOME/.config/rofi/network-manager"
rofi_command="rofi -theme $dir/$theme"

get_status()
{
    device_status=($(timeout 5s nmcli device status | grep "$device"))

    case "${device_status[2]}" in
        'connected')
            echo "$device connected to ${device_status[3]}"
            ;;
        'disconnected')
            echo "Not Connected"
            ;;
        '')
            echo -e "${device} device not found\nOR nmcli not responding" | $rofi_command -dmenu -markup-rows -i -p "Status"
            exit 1
            ;;
        *)
            echo -e "${device} device ${device_status[2]}" | $rofi_command -dmenu -markup-rows -i -p "Status"
            exit 1
            ;;
    esac
}


get_list()
{
    head="$(nmcli device wifi list ifname ${device} | head -1)"
    offset_of_MODE=$(echo "$head" | head -1 | awk -F 'MODE' '{print $1}')
    offset_m="${#offset_of_MODE}"

    offset_of_SIGNAL=$(echo "$head" | head -1 | awk -F 'SIGNAL' '{print $1}')
    offset_s="${#offset_of_SIGNAL}"

    while read line; do
        if [[ "${line:0:1}" == "*" ]]; then
            line="${line:8:-1}"
        fi

        ssid="$(echo "$line" | cut -b20-$(( offset_m - 9 )))"
        signal="$(echo "$line" | cut -b$(( offset_s  ))- | tr -s ' ' | cut -d ' ' -f2)"

        echo "$ssid| $signal |"
    done < <(nmcli device wifi list ifname "$device" | tail +2)
}


prompt()
{
    if [[ "$1" == "password" ]]; then
        add="-password"
    fi

    rofi -i $add -no-fixed-num-lines -theme "${dir}/prompt.rasi" -dmenu -p "${1}: "
}


connect()
{
    shopt -s extglob
    ssid="$1"
    ssid="${ssid%%*([[:blank:]])}"
#    echo "|$ssid|"

    if [[ "$ssid" == "" ]]; then
        exit 0;
    elif [[ "$ssid" == "hidden" ]]; then
        ssid="$(prompt "ssid")"
        hidden="yes"
    else
        hidden="no"
    fi

    password="$(prompt "password")"
    if [[ "$password" == "" ]]; then
        exit 0
    fi
#    echo "|$password|"

    notify-send "connecting..."
    result=$(nmcli device wifi connect "$ssid" password "$password" hidden "$hidden")
    notify-send "$result"
}


status=$(get_status)
[ $? -ne 0 ] && exit 1

ssid="$(get_list | $rofi_command -dmenu -markup-rows -i -p "$status")"
ssid="$(echo "$ssid" | cut -d '|' -f1)"

connect "$ssid"
