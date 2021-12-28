#!/bin/bash

# Add custom Titus rofi deb package
sudo dpkg -i 'Custom Packages/rofi_1.7.0-1_amd64.deb'

# Update routine
sudo apt update; sudo apt upgrade; sudo apt autoremove;

# Install necessary packages
sudo apt install unzip bspwm polybar rofi picom sddm kitty thunar flameshot neofetch sxhkd git lxpolkit lxappearance xorg htop sct brightnessctl alsa-utils pulseaudio pavucontrol variety libglib2.0-0 libglib2.0-bin feh mpv net-tools papirus-icon-theme fonts-noto-color-emoji fonts-firacode fonts-font-awesome fonts-ubuntu fonts-cantarell fonts-fantasque-sans libqt5svg5 qml-module-qtquick-controls ttf-mscorefonts-installer

# Download Nordic Theme
git clone https://github.com/EliverLara/Nordic.git
sudo cp -r Nordic /usr/share/themes/

# Copy input device configurations
sudo cp etc_X11_xorg.conf.d/* /etc/X11/xorg.conf.d/
#sudo cp usr_share_X11_xorg.conf.d/* /usr/share/X11/xorg.conf.d/

# Make folders
mkdir -p ~/.themes ~/.fonts ~/.config

# Copy user configuration files
cp -r config-files/* ~/.config/

# Fira Code Nerd Font variant needed
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d ~/.fonts
fc-cache -vf

# lxapearance
cp .Xresources ~
cp .Xnord ~
