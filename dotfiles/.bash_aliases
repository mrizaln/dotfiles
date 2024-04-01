# helper functions
_create_alias_script() {
    if [[ -z "$1" || -z "$2" ]]; then
        >&2 echo "$FUNCNAME failed: not enough arguments '$@'"
        return 1
    fi

    local alias_name="$1"
    local script_path="$2"

    if [[ -x "$script_path" ]]; then
        alias "$alias_name"="$script_path"
        return 0
    else
        >&2 echo "$FUNCNAME failed: '$script_path' is not executable"
        return 1
    fi
}

_create_alias_command() {
    if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
        >&2 echo "$FUNCNAME failed: not enough arguments '$@'"
        return 1
    fi

    local alias_name="$1"
    local test_command="$2"
    local command="$3"

    if which "$test_command" &> /dev/null; then
        alias "$alias_name"="$command"
        return 0
    else
        >&2 echo "$FUNCNAME failed: '$test_command' is not found"
        return 1
    fi
}


#-----------------------------[ coreutil aliases ]------------------------------
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls aliases
alias lla='ls -vhalF'
alias ll='ls -vhlF'
alias la='ls -vhAF'
alias l='ls -vhCF'

alias lh='ls -vhdF .?*'       # list only hidden files
alias llh='ls -vhdFl .?*'     # list only hidden files with details
alias lsd='ls -vd */'

# list symbolic links
_list_symlinks() {
    ls -lahF "$@" --color=always              \
        | grep "\->"                          \
        | tr -s " "                           \
        | cut -d\  -f9-                       \
        | awk -F '->' '{print $1 " :-> " $2}' \
        | column -s ':' -t -l2
}
alias lll=_list_symlinks

# list symbolic links recursively (max depth: 3)
_list_symlinks_recursive() {
    find "$HOME" -maxdepth 3 -lname "*$1*" -exec ls -lFhd --color=always {} \; \
        | tr -s " "                                                            \
        | cut -d\  -f9-                                                        \
        | awk -F '-> ' '{print $1 ":->\t" $2}'                                 \
        | column -s ':' -t -l2;
}
alias llld=_list_symlinks_recursive

# cd then immediately ls
_cdl_impl() {
    cd "$@"
    ls -hCF
}
alias cdl=_cdl_impl

# have you ever been deep inside a file strucure? yeah, like java project file strucuture.
# fear no more, you can use this command to go up the directory structure many times you like
_cd_up_many_times() {
    if [[ $1 == ?(-)+([0-9]) ]]; then
        echo "from: $(pwd)"
        local N="$1"
        cd $(for i in $(seq $N); do echo -n "../"; done)
        echo "to  : $(pwd)"
    elif [[ -z "$1" ]]; then
        echo "usage: <this_command> <NUM>"
    else
        echo "enter number, not string"
    fi
}
alias cd..=_cd_up_many_times

alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# make du command human-readable without explicitly type the option
alias du='du -h'

# run these program in interactive mode
alias mv="mv -i"
alias rm="rm -I"

# aliasing du to print in sorted-human-readable format
alias du_sorted='du -hd1 | sort -h'

# print PATHs
alias print_path='echo -e "${PATH//:/\\n}" | sort'


#-----------------------------[ command aliases ]-------------------------------
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
_create_alias_command alert notify-send 'notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# make reboot command interactive
_create_alias_command reboot reboot 'echo "are you sure? [y/n]" && read x && [ "$x" = "y" ] && reboot'

# make powertop to run as root priviledge on default
_create_alias_command powertop powertop 'sudo powertop'

# convert .doc .docx .ppt .pptx .pps .ppsx into .pdf file using libreoffice
_create_alias_command libreoffice_conv libreoffice 'libreoffice --headless --convert-to pdf'

# htop but gpu
_create_alias_command gtop nvidia-smi 'watch -n 1 nvidia-smi'

# aliasing feh to open in certain geometry and other control
_create_alias_command fehh feh 'feh -g 960x540 -d --scale-down --start-at'

# alias for easier access to vi config
_create_alias_command nvim-config vi 'vi ~/.config/nvim/init.lua'

# open nvim using old init.vim file to open
_create_alias_command nvim-old nvim 'nvim -u ~/.config/nvim/init.vim.bak'

# openg nvim using a minimal configuration
# _create_alias_command nvim-minimal nvim 'nvim -u ~/.config/nvim/init.vim.minimal'
_create_alias_command nvim-minimal nvim 'nvim --cmd "let g:init_minimal = v:true"'

# aliases nvimdiff (idk why it didn't shipped with nvim package)
if ! which nvimdiff &> /dev/null; then
    _create_alias_command nvimdiff nvim 'nvim-minimal -d'
fi

# aliases nvim that opens :DiffviewOpen
_create_alias_command nvim-diffview nvim 'nvim-minimal -c DiffviewOpen'

# why discord capitalize its name?
_create_alias_command discord Discord Discord

# g++ with -std=c++20
_create_alias_command g++20 g++ 'g++ -std=c++20'

# lazygit
_create_alias_command lgit lazygit lazygit

# display ripgrep result in less
_rgl_impl() {
    rg -p "$@" | less -RFX
}
_create_alias_command rgl rg _rgl_impl

# display ripgrep result in delta
_rgd_impl() {
    command env rg --json "$@" | delta
}
_create_alias_command rgd rg _rgd_impl

# ffmpeg alias for nvidia gpu acceleration using nvenc
# _create_alias_command ffmpeg_nvenc ffmpeg 'ffmpeg -hwaccel cuda -hwaccel_output_format cuda -c:v h264_nvenc -preset slow -rc vbr_hq -cq 19 -b:v 0 -c:a aac -b:a 128k -ac 2 -f mp4'
_create_alias_command ffmpeg_nvenc ffmpeg 'ffmpeg -hwaccel cuda -hwaccel_output_format cuda -c:a copy -vcodec hevc_nvenc -preset p1 -c:s copy -y'

_xxd_color_with_pager() {
    xxd -R always "$@" | less -F -R
}
_create_alias_command xxd xxd _xxd_color_with_pager

# alias to wshowkeys with customization for easier access
_create_alias_command display_keys wshowkeys 'wshowkeys -a bottom -a right -F "JetBrainsMono Nerd Font Ultra-Bold 30" -b "#1E203080" -f "#E8EFFF"'


#-----------------------------[ script aliases ]--------------------------------
# use mv_ln instead of mv
_create_alias_script nmv ~/.local/bin/move_and_relink.py

# check disk usage
_create_alias_script cdisk ~/.local/bin/check_disk_usage.py


#-----------------------------[ other aliases ]---------------------------------
# nvidia run
_nvidia_run_impl()
{
    local dgpu=$(lspci | grep "3D controller:" | cut -d\  -f2-4 | cut -d: -f2)
    if [[ ${dgpu// /} == NVIDIA ]]; then     # remove any whitespace
        echo ">>> Discrete NVIDIA GPU selected."
        __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
    else
        echo ">>> No NVIDIA dGPU found"
    fi
}
_nvidia_run_completion() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(compgen -c -- "$cur"))
}

alias nvidia_run=_nvidia_run_impl
complete -F _nvidia_run_completion nvidia_run

# alias 'npx tsc' for easier call and similar to when call 'node'
_node_run_ts()
{
    local file="$1"
    if [[ "${file:$((${#file}-2))}" != "ts" ]]; then
        echo "Not a ts file";
        return 1
    fi

    local js_file="${file:0:$((${#file}-2))}js"
    echo -e "compiling to: [$js_file]\n"
    npx tsc "$file"

    if [[ $? != 0 ]]; then return; fi

    node "$js_file"
}
alias nodet="_node_run_ts"

# # alising time(1) because more than one program exist with the same name
# alias timee="$(which time) -f '\t%E real,\t%U user,\t%S sys,\t%K amem,\t%M mmem'"

# convert jsonl to json
_jsonl_to_json_impl() {
    local file="$1" # accept one input only
    jq -c --slurp . < "$file" > "${file%.*}.json"
}
alias jsonl_to_json=_jsonl_to_json_impl

if which conan &> /dev/null && which notify-send &> /dev/null; then
    _conan_with_notification() {
        conan "$@" && notify-send "Conan task completed" || notify-send -u critical "Conan task failed"
    }
    alias conan_notify="_conan_with_notification"
fi
