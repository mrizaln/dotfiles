#!/bin/env bash

# Install rofi deb package
sudo dpkg -i 'others/rofi_1.7.0-1_amd64.deb'

# Update routine
sudo apt update; sudo apt upgrade; sudo apt autoremove;

# Install necessary packages
sudo apt install python3 unzip bspwm polybar rofi picom sddm kitty thunar flameshot neofetch sxhkd dunst git lxpolkit lxappearance xorg htop sct brightnessctl alsa-utils pulseaudio pavucontrol variety libglib2.0-0 libglib2.0-bin feh mpv net-tools vnstat papirus-icon-theme fonts-noto-color-emoji fonts-noto-cjk fonts-firacode fonts-font-awesome fonts-ubuntu fonts-cantarell fonts-fantasque-sans libqt5svg5 qml-module-qtquick-controls openssh-client openssh-server ttf-mscorefonts-installer

# Download Nordic Theme
git clone https://github.com/EliverLara/Nordic.git
sudo cp -r Nordic /usr/share/themes/

# Copy input device configurations
sudo cp additional-config-files/etc_X11_xorg.conf.d/* /etc/X11/xorg.conf.d/
#sudo cp additional-config-files/usr_share_X11_xorg.conf.d/* /usr/share/X11/xorg.conf.d/

# Make theme folders
mkdir -p ~/.themes ~/.fonts ~/.config

# Copy user configuration files
cp -r config-files/* ~/.config/

# Data Partition Mount Service (assuming using systemd)
if [ $USER == mrizaln ]; then
    sudo cp others/mnt-46B691EEB691DF2D.mount /etc/systemd/system/
    sudo systemctl enable mnt-46B691EEB691DF2D.mount
fi

# Low Battery Warn Service
mkdir -p ~/.config/systemd/{user,scripts}
cp additional-scripts/battery-warn.* ~/.config/systemd/user/
cp additional-scripts/battery.sh ~/.config/systemd/scripts/

# Download mpris indicator for polybar
#wget https://raw.githubusercontent.com/polybar/polybar-scripts/master/polybar-scripts/player-mpris-tail/player-mpris-tail.py
#wget https://raw.githubusercontent.com/polybar/polybar-scripts/master/polybar-scripts/pulseaudio-microphone/pulseaudio-microphone.sh
#chmod +x player-mpris-tail.py pulseaudio-microphone.sh
#mv player-mpris-tail.py pulseaudio-microphone.sh ~/.config/polybar/polybar-scripts/

# Install Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.fonts/
fc-cache -vf

# X appearance
sed "s/mrizaln/$USER/" -i .Xresources       # if username is not mrizaln, replace it with $USER
cp .Xresources ~
cp .Xnord ~

# Installing rtl8821ce driver, just in case
if [[ "$(lspci | grep -i rtl8821ce | wc -l)" == 1 ]]; then
    sudo apt install bc module-assistant build-essential dkms
    git clone https://github.com/tomaspinho/rtl8821ce
    cd rtl8821ce
    sudo ./dkms-install.sh
fi

# Installing network-manager package
# it needs to be the last, because for some reason it makes already connected network unreachable
sudo apt install network-manager

echo -e "\n\n\n==============[ NOW RESTART YOUR COMPUTER ]==============="
