# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH to include system binary
PATH="$PATH:/usr/sbin:/sbin"

# set PATH to include android studio
PATH="$PATH:/home/mrizaln/android-studio/bin"

# to fix some java application window not rendering properly
if [[ "$XDG_SESSION_DESKTOP" = "bspwm" || "$DESKTOP_SESSION" = "bspwm" ]] ; then
    export _JAVA_AWT_WM_NONREPARENTING=1
#    export AWT_TOOLKIT=MToolkit
fi

# to enable IME on kitty terminal
#if [[ "$TERM" == "xterm-kitty" ]]; then
    export GLFW_IM_MODULE=ibus
#fi

# fix scaling issues qt
export QT_ENABLE_HIGHDPI_SCALING=0

# fix anki scaling issue
export ANKI_NOHIGHDPI=1

# fix gtk4 application not using Nordic theme
export GTK_THEME=Nordic

. "$HOME/.cargo/env"

# force qt to use kvantum themes
export QT_STYLE_OVERRIDE=kvantum
