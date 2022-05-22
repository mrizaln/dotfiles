#!/bin/bash

cd $HOME

ker_bef="$(cat $HOME/kernel_version 2> /dev/null)"
ker_aft=$(uname -r)

if [ "$ker_bef" = "$ker_aft" ]; then
    exit
else
    echo
    echo '::: I detected that your system kernel has been updated'
    echo '::: Some software need to be reinstalled to make them available like before'
    echo
    echo '::: Kernel version info:'
    echo "              last kernel version          : $ker_bef"
    echo "              current kernel version       : $ker_aft"
    echo
    echo '::: Allow software reinstallation? (y/n, default: n)'
    read r

    if [ "$r" = "y" ]; then
        ## i want to know how to properly prompt for elevated permission other than this
        sudo echo

        ## installing veikk pentab driver, i need this cause i want to be able to draw :)
        veikk_install.sh

        # droidcam_install.sh             ## i need to comment this line because i want to avoid v42l video loopback conflict with obs-studio. unless the issue has been resolved, this line will be commented

        ### just fill this line and after it if you want to add more installation instruction, just dont past the line where kernel_version reside

        echo $(uname -r) > kernel_version
    else
        echo
        echo cancelled
        echo
    fi

fi
