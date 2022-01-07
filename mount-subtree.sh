#!/bin/bash

mkdir -p config-files etc_X11_xorg.conf.d usr_share_X11_xorg.conf.d

sudo mount --bind ~/.config config-files/
sudo mount --bind /etc/X11/xorg.conf.d/ etc_X11_xorg.conf.d/
sudo mount --bind /usr/share/X11/xorg.conf.d/ usr_share_X11_xorg.conf.d/
