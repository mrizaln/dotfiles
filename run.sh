#!/bin/env bash

SYSTEM=$(cat /etc/os-release | grep -E ^ID | cut -d= -f2)
echo "You are using: $SYSTEM"
if [[ "$SYSTEM" != "fedora" || "$SYSTEM" != "debian" || "$SYSTEM" != "ubuntu" ]]; then
    echo "I'm sorry but $SYSTEM is not configured for now"
    echo "You need to install the packages manually"
    echo "The config-files/ and scripts/ can still be used"
    echo "You need to copy those manually as well"
    exit 1
fi

update_system()
{
    if [[ "$SYSTEM" == "debian" || "$SYSTEM" == "ubuntu" ]]; then
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    elif [[ "$SYSTEM" == "fedora" ]]; then
        sudo dnf update
    else
        echo "Unknown system"
        return
    fi
}

install_package()
{
    local cmd
    if [[ "$SYSTEM" == fedora ]]; then
        cmd="sudo dnf install -y"
    elif [[ "$SYSTEM" == "debian" || "$SYSTEM" == "ubuntu" ]]; then
        cmd="sudo apt install -y"
    else
        echo "Unknown system"
        return
    fi
    $cmd "$@"
}

install_essential()
{
    install_package bspwm polybar rofi picom sxhkd dunst git unzip rxvt-unicode thunar alsa-utils pavucontrol feh mpv vnstat net-tools brightnessctl sddm
}

install_nonessential()
{
    local ssh_client=$([[ "$SYSTEM" == "fedora" ]] && echo openssh-clients || echo openssh-client)
    install_package htop neofetch lxpolkit lxappearance papirus-icon-theme openssh-server $ssh_client
}

install_appearance()
{
    # make theme folders
    mkdir -p ~/.themes ~/.fonts

    # fonts
    if [[ "$SYSTEM" == fedora ]]; then
        sudo dnf install -y google-noto-cjk-fonts google-noto-color-emoji-fonts fira-code-fonts jetbrains-mono-fonts fontawesome-fonts

        # ubuntu fonts
        sudo dnf copr enable atim/ubuntu-fonts -y && sudo dnf install -y ubuntu-family-fonts

        # microsoft fonts
        sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
        sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

    elif [[ "$SYSTEM" == "debian" || "$SYSTEM" == "ubuntu" ]]; then
        sudo apt install -y fonts-noto-cjk fonts-noto-color-emoji fonts-firacode fonts-jetbrains-mono fonts-font-awesome fonts-ubuntu fonts-cantarell fonts-fantasque-sans ttf-mscorefonts-installer
    fi

    # nerd fonts
    #
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
    unzip FiraCode.zip -d ~/.fonts
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
    unzip Meslo.zip -d ~/.fonts
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
    unzip JetBrainsMono.zip -d ~/.fonts/
    fc-cache -vf
 
    # download Nordic Theme
    git clone https://github.com/EliverLara/Nordic.git
    sudo cp -r Nordic /usr/share/themes/
}

configure_system()
{
    mkdir -p ~/.config
 
    # copy user configuration files
    cp -r config-files/* ~/.config/

    # copy scripts
    mkdir -p ~/.local/bin
    cp -r scripts/* ~/.local/bin

    # low battery warn service
    mkdir -p ~/.config/systemd/{user,scripts}
    cp additional-scripts/battery-warn.* ~/.config/systemd/user/
    cp additional-scripts/battery.sh ~/.config/systemd/scripts/

    # X appearance
    sed "s/mrizaln/$USER/" -i .Xresources       # if username is not mrizaln, replace it with $USER
    cp .Xresources ~
    cp .Xnord ~

    # copy input device configurations
    sudo cp additional-config-files/etc_X11_xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/
}

update_system
install_essential
install_nonessential
install_appearance
configure_system

# installing network-manager package
# it needs to be the last, because for some reason it makes already connected network unreachable
install_package network-manager$([[ "$SYSTEM" == "fedora" ]] && echo "-applet")

echo -e "\n\n\n==============[ NOW RESTART YOUR COMPUTER ]==============="
