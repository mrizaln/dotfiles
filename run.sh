#!/bin/bash

# Add custom Titus rofi deb package
sudo dpkg -i 'others/rofi_1.7.0-1_amd64.deb'

# Update routine
sudo apt update; sudo apt upgrade; sudo apt autoremove;

# Install necessary packages
sudo apt install unzip bspwm polybar rofi picom sddm kitty thunar flameshot neofetch sxhkd dunst git lxpolkit lxappearance xorg htop sct brightnessctl alsa-utils pulseaudio pavucontrol variety libglib2.0-0 libglib2.0-bin feh mpv net-tools papirus-icon-theme fonts-noto-color-emoji fonts-firacode fonts-font-awesome fonts-ubuntu fonts-cantarell fonts-fantasque-sans libqt5svg5 qml-module-qtquick-controls ttf-mscorefonts-installer

# Download Nordic Theme
git clone https://github.com/EliverLara/Nordic.git
sudo cp -r Nordic /usr/share/themes/

# Copy input device configurations
sudo cp etc_X11_xorg.conf.d/* /etc/X11/xorg.conf.d/
#sudo cp usr_share_X11_xorg.conf.d/* /usr/share/X11/xorg.conf.d/

# Make theme folders
mkdir -p ~/.themes ~/.fonts ~/.config

# Copy user configuration files
cp -r config-files/* ~/.config/

# Download mpris indicator for polybar
wget https://raw.githubusercontent.com/polybar/polybar-scripts/master/polybar-scripts/player-mpris-tail/player-mpris-tail.py
chmod +x player-mpris-tail.py
mv player-mpris-tail.py ~/.config/polybar/polybar-scripts/

# Install Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.fonts/
fc-cache -vf

# lxapearance
cp .Xresources ~
cp .Xnord ~

# Installing rtl8821ce driver, in case
sudo apt install bc module-assistant build-essential dkms
git clone https://github.com/tomaspinho/rtl8821ce
cd rtl8821ce
sudo ./dkms-install.sh

# Installing network-manager package
# it needs to be the last, because for some reason it makes already connected network unreachable
sudo apt install network-manager

echo -e "\n\n\n==============[ NOW RESTART YOUR COMPUTER ]==============="
