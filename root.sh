#!/bin/bash

# Add Custom Titus Rofi Deb Package
dpkg -i 'Custom Packages/rofi_1.7.0-1_amd64.deb'

# Update packages list
apt update

# Add base packages
apt install unzip picom bspwm polybar sddm rofi kitty thunar flameshot neofetch sxhkd git lxpolkit lxappearance xorg htop sct xbrightness alsa-utils pulseaudio pavucontrol variety libglib2.0-0 libglib2.0-bin feh mpv net-tools

# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git

# Move input devices configuration
cp etc_X11_xorg.conf.d/* /etc/X11/xorg.conf.d/
#cp usr_share_X11_xorg.conf.d/* /usr/share/X11/xorg.conf.d/

