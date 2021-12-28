#!/bin/bash

# Appearance packages
sudo apt install papirus-icon-theme lxappearance fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls

# Make Theme folders
mkdir -p ~/.themes ~/.fonts ~/.config

# Fira Code Nerd Font variant needed
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d ~/.fonts
fc-cache -vf

#Ms-fonts
sudo apt install ttf-mscorefonts-installer

echo "RUN LXAPPEARANCE"
cd ../
cp .Xresources ~
cp .Xnord ~
cp -R config-files/* ~/.config/
