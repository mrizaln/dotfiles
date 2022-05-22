#!/bin/env bash

case $1 in
    "")
        mkdir -p config-files additional-config-files/etc_X11_xorg.conf.d additional-config-files/usr_share_X11_xorg.conf.d

        sudo mount --bind ~/.local/bin/ scripts/
        sudo mount --bind ~/.config/ config-files/
        sudo mount --bind /etc/X11/xorg.conf.d/ additional-config-files/etc_X11_xorg.conf.d/
        sudo mount --bind /usr/share/X11/xorg.conf.d/ additional-config-files/usr_share_X11_xorg.conf.d/
        ;;
    "unmount")
        sudo umount scripts/
        sudo umount config-files/
        sudo umount additional-config-files/etc_X11_xorg.conf.d/
        sudo umount additional-config-files/usr_share_X11_xorg.conf.d/
        ;;
    *)
        echo argument not understood
        echo usage: $0 [unmount]
esac

