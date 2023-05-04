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
# if [ -d /usr/sbin ] ; then
# PATH="/usr/sbin:/sbin:$PATH"
# fi

# set PATH to include android studio
# PATH="$HOME/android-studio/bin:$PATH"

# add Mason bin to PATH
if [ -d "$HOME/.local/share/nvim/mason/bin" ] ; then
    PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
fi

# add application installed downloaded manually
if [ -d "$HOME/Apps/bin" ]; then
    PATH="$HOME/Apps/bin:$PATH"
fi

# to fix some java application window not rendering properly
if [[ "$XDG_SESSION_DESKTOP" = "bspwm" || "$DESKTOP_SESSION" = "bspwm" ]] ; then
    export _JAVA_AWT_WM_NONREPARENTING=1
#    export AWT_TOOLKIT=MToolkit
fi

# to enable IME on kitty terminal
if [[ "$TERM" == "xterm-kitty" ]]; then
    export GLFW_IM_MODULE=ibus
    export GTK_IM_MODULE=ibus
fi

# fix scaling issues qt
export QT_ENABLE_HIGHDPI_SCALING=0

# fix anki scaling issue
export ANKI_NOHIGHDPI=1

# fix gtk4 application not using Nordic theme (breaks GNOME 43 spacing)
# https://github.com/EliverLara/Nordic/issues/237
if [[ "$DESKTOP_SESSION" == i3 ]]; then
    export GTK_THEME=Nordic
# else
    # export GTK_THEME=Nordic-darker-v40
fi

# force qt to use kvantum themes
export QT_STYLE_OVERRIDE=kvantum

# use nvim as editor
if which nvim &> /dev/null; then
    export VISUAL=nvim
    export EDITOR="$VISUAL"
else
    export VISUAL=vi
    export EDITOR="$VISUAL"
fi

# set JAVA_HOME
# export JAVA_HOME=/home/mrizaln/.sdkman/candidates/java/current
