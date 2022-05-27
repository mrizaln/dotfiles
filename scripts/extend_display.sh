#!/bin/env bash

generate_mode ()
{
    width=$1
    height=$2
    refresh_rate=$3

    mode=($(cvt $width $height $refresh_rate | tail -1 | cut -d\  -f2-))
    mode_identifier=${mode[0]//\"/}                                             # remove double quotation marks
    mode=${mode[@]//\"/}

    echo -e "\ngenerating mode: ${mode_identifier} ..."

    xrandr --newmode $mode
    xrandr --addmode HDMI-A-0 "$mode_identifier"
}

activate_mode ()
{
    mode=$1
    position=$2

    echo -e "\nactivating mode"

    xrandr --output HDMI-A-0 --mode $mode $position eDP
}

delete_mode ()
{
    mode_identifier=$1

    echo -e "\ndeleting mode: ${mode_identifier} ..."

    xrandr --output HDMI-A-0 --off
    xrandr --delmode HDMI-A-0 "$mode_identifier"
    xrandr --rmmode "$mode_identifier"
}

run_vnc ()
{
    width=$1
    height=$2
    offset=$3

    echo -e "\nstarting vnc at ${width}x${height}${offset}"

    x11vnc -clip "${width}x${height}${offset}" -repeat -passwd password #-unixpw #-vencrypt nodh:only -ssl
}

run_polybar ()
{
    killall -q polybar

    # Wait until the processes have been shut down
    while pgrep -u $UID -x polybar > /dev/null; do sleep 0.5; done

    for m in $(polybar -m | cut -d: -f1); do
        MONITOR=$m polybar --reload bar 2> /dev/null &
    done
}

main ()
{
    res="$1"
    while true; do
        case "$res" in
            720)
                width=1280
                height=720
                break
                ;;
            768)
                width=1366
                height=768
                break
                ;;
            *)
                echo "Invalid resolution.";
                read -p "resolution(720/768): " res
                echo
                ;;
        esac
    done

    pos="$2"
    offset=""
    while true; do
        case "$pos" in
            "--above")
                offset="+0-${height}"
                break
                ;;
            "--below")
                offset="+0+${height}"
                break
                ;;
            "--left-of")
                offset="-${width}+0"
                break
                ;;
            "--right-of")
                offset="+${width}+0"
                break
                ;;
            *)
                echo -e "Invalid position.\nAllowed position: --above, --below, --left-of, --right-of"
                read -p "position: " pos
                echo
                ;;
        esac
    done

    connect_method="$3"
    if [[ "$connect_method" = "usb" ]]; then
    

    frame_rate=60

    generate_mode $width $height $frame_rate
    activate_mode "$mode_identifier" "$pos"
    sleep 1     # wait for a while
    run_polybar                                 # create instances of polybar on each monitor
    run_vnc $width $height "$offset"
    delete_mode "$mode_identifier"
    run_polybar                                 # recreate polybar instance on main monitor (and kill previous instance on deleted mode)

    echo "exiting."

    exit 0
}

main $1 $2

exit 0
