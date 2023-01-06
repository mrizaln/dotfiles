#!/bin/env bash

BUILT_IN_HEIGHT=768
BUILT_IN_WIDTH=1366

generate_mode ()
{
    width=$1
    height=$2
    refresh_rate=$3

    mode=($(cvt $width $height $refresh_rate | tail -n1 | cut -d\  -f2-))
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


adb_reverse_connection ()
{
    device="$1"
    port="5900"     # default vnc port
    if [[ "$2" != "" && "$2" =~ ^[0-9]+$ ]]; then port="$2"; fi
    adb connect $device
    adb reverse tcp:"$port" tcp:"$port"
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
            '720')
                width=1280
                height=720
                break
                ;;
            '768')
                width=1366
                height=768
                break
                ;;
            '720-')
                width=1520
                height=720
                break
                ;;
            '768-')
                width=1621
                height=768
                break
                ;;
            '1080')
                width=1920
                height=1080
                break
                ;;
            *)
                echo "Invalid resolution.";
                read -p "resolution(720/768/1080): " res
                echo
                ;;
        esac
    done

    pos="$2"
    offset=""
    while true; do
        case "$pos" in
            "--above")
                offset="+0-${BUILT_IN_HEIGHT}"
                break
                ;;
            "--below")
                offset="+0+${BUILT_IN_HEIGHT}"
                break
                ;;
            "--left-of")
                offset="-${width}+0"
                break
                ;;
            "--right-of")
#                offset="+${width}+0"
                offset="+BUILT_IN_WIDTH+0"
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
    if [[ "$connect_method" = "" ]]; then
        read -p "what connection method to use? (wlan/usb/hdmi) " connect_method
    fi

    use_vnc=true

    if [[ "$connect_method" = "usb" ]]; then
        devices=$(adb devices | tail -n+2 | awk -F ' ' '{print $1}')
        echo "$devices" | cat -n
        devices=($devices)
        read -p "choose device: " num
        num=$((num - 1))
        device="${devices[$num]}"

        adb_reverse_connection "$device"

    elif [[ "$connect_method" == "hdmi" ]]; then
        use_vnc=false
    fi

    frame_rate=60

    generate_mode $width $height $frame_rate
    activate_mode "$mode_identifier" "$pos"
    sleep 1     # wait for a while

    run_polybar                                 # create instances of polybar on each monitor

    if [[ "$use_vnc" == false ]]; then
        echo -e "\n\n\ndisplay extended to ${pos:2} the screen \nextended resolution is: ${width}x${height}"
        while true; do
            read -p "[k]eep & exit/[D]elete & exit? " ans

            case "$ans" in
                'k')
                    ;&
                'K')
                    break;
                    ;;

                '')
                    ;&
                'd')
                    ;&
                'D')
                    delete_mode "$mode_identifier"
                    break;
                    ;;
                *)
                    echo "invalid input, try again."
                    ;;
            esac
        done
    else
        run_vnc $width $height "$offset"
        delete_mode "$mode_identifier"
    fi

    run_polybar                                 # recreate polybar instance on main monitor (and kill previous instance on deleted mode)

    echo "exiting."

    exit 0
}

main $1 $2 $3

exit 0
