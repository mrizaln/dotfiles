# more more ls aliases
alias lh='ls -hdF .?*'       # list only hidden files
alias llh='ls -hdFl .?*'     # list only hidden files with details
alias lsd='ls -d */'

lll(){ ( ls -lahF "$@" --color=always | grep "\->" | tr -s " " | cut -d\  -f9- | awk -F '->' '{print $1 " :-> " $2}' | column -s ':' -t -l2 ) }     # list link files; not alias but, eh

llld(){ find "$HOME" -maxdepth 3 -lname "*$1*" -exec ls -lFhd --color=always {} \; | tr -s " " | cut -d\  -f9- | awk -F '-> ' '{print $1 ":->\t" $2}' | column -s ':' -t -l2; }

# rename or move file/directory also relink all symbolic link that points to it
mv_ln() {
    if [[ -L "$1" ]]; then      # if it is a symlink, dont bother about relinking 
        [[ -z "$2" ]] && return
        mv "$1" "$2"
    elif [[ -n "$1" ]]; then
        local name="${1%/}"       # read first parameter then remove trailing slash
        local new_name="${2%/}"   # read second parameter then remove trailing slash

        local dir="$3"            # optional parameter: where to search links
        [[ -z "$dir" ]] && dir="$HOME"

        local affected_links="$(find "$dir" -maxdepth 10 -lname "*${name}*")"  # prevents the shell to prematurely expand wild card
        if [[ -z "$affected_links" ]]; then
            mv "$name" "$new_name"
            return;
        fi
        local links_destination="$(echo "${affected_links}" | while read link; do ls -lFh "$link"; done | tr -s " " | cut -d\  -f9- | awk -F '-> ' '{print$2}')"

        local affected_links_list
        local links_destination_list
        readarray -t affected_links_list <<< "$affected_links"
        readarray -t links_destination_list <<< "$links_destination"

        echo "Modification will be applied to these files:"
        for i in ${!affected_links_list[@]}; do
            echo -e "\t ${affected_links_list[i]}   :->   ${links_destination_list[i]/$name/\\033[34m$new_name\\033[0m}"        # add highlighting
        done | column -s ':' -t -l2

        local ans
        read -p "Continue [Y/n]? " ans

        case $ans in
            '')  ;&
            'y') ;&
            'Y') ;;
            *) echo "Aborted"; return ;;
        esac

        echo "Moving file/directory"
        mv "$name" "$new_name"

        # relink the symlinks
        echo "Relinking"
        for i in ${!affected_links_list[@]}; do
            local link="${affected_links_list[i]}"
            local target="${links_destination_list[i]/$name/$new_name}"

            rm "$link"
            ln -s "${target%/}" "${link%/}"
        done
        echo "Done"
    else
        echo "usage: mv_ln <from> <to>"
        echo "from is the directory suspected to be inside some symbolic link"
    fi
}

# use mv_ln instead of mv
alias nmv=mv_ln

# nvidia run
nvidia_run()
{
    local dgpu=$(lspci | grep "3D controller:" | cut -d\  -f2-4 | cut -d: -f2)
    if [[ $dgpu == NVIDIA ]]; then
        __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
    else
        echo "No NVIDIA dGPU found"
    fi
}

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

# aliasing python3 as python
#alias python='python3'

# aliasing nanora.sh as nanora
alias nanora='nanora.sh'

# aliasing du to print in sorted-human-readable format
alias du_sorted='du -hd1 | sort -h'

# aliasing feh to open in certain geometry and other control
alias fehh="feh -g 960x540 -d --scale-down --start-at"

# alising time(1) because more than one program exist with the same name
alias timee="$(which time) -f '\t%E real,\t%U user,\t%S sys,\t%K amem,\t%M mmem'"

# git push but before that copies git token first
alias git_pushh="git_token_copy.sh; git push"

# alias for anki from flatpak
#if [ -e /var/lib/flatpak/app/net.ankiweb.Anki/current/active/files/bin/anki ]; then
    alias anki="ANKI_NOHIGHDPI=1 flatpak run net.ankiweb.Anki"
#fi

# android studio
alias android_studio_launch='JAVA_AWT_WM_NONREPARENTING=1 ~/android-studio/bin/studio.sh'

# alias for easier access to vi config
alias viconfig="vi ~/.config/nvim/init.lua"

# open nvim using old init.vim file to open
alias nvim-old="nvim -u ~/.config/nvim/init.vim.bak"

# openg nvim using a minimal configuration
alias nvim-minimal="nvim -u ~/.config/nvim/init.vim.minimal"

# aliases nvimdiff (idk why it didn't shipped with nvim package
#alias nvimdiff="nvim -d"
