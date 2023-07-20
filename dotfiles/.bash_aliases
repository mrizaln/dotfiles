# more more ls aliases
alias lh='ls -hdF .?*'       # list only hidden files
alias llh='ls -hdFl .?*'     # list only hidden files with details
alias lsd='ls -d */'

# cd then immediately ls
_cdl() {
    cd "$@"
    ls -hCF
}
alias cdl=_cdl

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

lll(){ ( ls -lahF "$@" --color=always | grep "\->" | tr -s " " | cut -d\  -f9- | awk -F '->' '{print $1 " :-> " $2}' | column -s ':' -t -l2 ) }     # list link files; not alias but, eh

llld(){ find "$HOME" -maxdepth 3 -lname "*$1*" -exec ls -lFhd --color=always {} \; | tr -s " " | cut -d\  -f9- | awk -F '-> ' '{print $1 ":->\t" $2}' | column -s ':' -t -l2; }

# use mv_ln instead of mv
if [[ -x ~/.local/bin/move_and_relink.sh ]]; then
    alias nmv=~/.local/bin/move_and_relink.sh
fi

# nvidia run
nvidia_run()
{
    local dgpu=$(lspci | grep "3D controller:" | cut -d\  -f2-4 | cut -d: -f2)
    if [[ ${dgpu// /} == NVIDIA ]]; then     # remove any whitespace
        __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
    else
        echo "No NVIDIA dGPU found"
    fi
}

# alias 'npx tsc' for easier call and similar to when call 'node'
node_run_ts()
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
alias nodet="node_run_ts"

# make du command human-readable without explicitly type the option
alias du='du -h'

# make reboot command interactive
alias reboot='echo "are you sure? [y/n]" && read x && [ "$x" = "y" ] && reboot'

# make powertop to run as root priviledge on default
alias powertop='sudo powertop'

# convert .doc .docx .ppt .pptx .pps .ppsx into .pdf file using libreoffice
alias libroff_conv='libreoffice --headless --convert-to pdf'

# download videos from youtube
alias yt_down_vid='youtube-dl'              # as video (best quality)
alias yt_down_mp3='youtube-dl -x --audio-format mp3'    # as audio (mp3)

# aliasing nanora.sh as nanora
alias nanora='nanora.sh'

# aliasing du to print in sorted-human-readable format
alias du_sorted='du -hd1 | sort -h'

# check disk usage
alias cdisk='~/.local/bin/check_disk_usage.py'

# htop but gpu
alias gtop='watch -n1 nvidia-smi'

# aliasing feh to open in certain geometry and other control
alias fehh="feh -g 960x540 -d --scale-down --start-at"

# # alising time(1) because more than one program exist with the same name
# alias timee="$(which time) -f '\t%E real,\t%U user,\t%S sys,\t%K amem,\t%M mmem'"

# alias for anki from flatpak
#if [ -e /var/lib/flatpak/app/net.ankiweb.Anki/current/active/files/bin/anki ]; then
    # alias anki="ANKI_NOHIGHDPI=1 flatpak run net.ankiweb.Anki"
#fi

# alias for easier access to vi config
alias viconfig="vi ~/.config/nvim/init.lua"

# open nvim using old init.vim file to open
alias nvim-old="nvim -u ~/.config/nvim/init.vim.bak"

# openg nvim using a minimal configuration
# alias nvim-minimal="nvim -u ~/.config/nvim/init.vim.minimal"
alias nvim-minimal='nvim --cmd "let g:init_should_skip_lsp = v:true"'

# aliases nvimdiff (idk why it didn't shipped with nvim package
alias nvimdiff='nvim-minimal -d'

# aliases nvim that opens :DiffviewOpen
alias nvim-diffview='nvim-minimal -c DiffviewOpen'

# why discord use capitalize its name?
if which Discord &> /dev/null; then
    alias discord=Discord
fi
