#!/usr/bin/env bash

home="/home/mrizaln"

BASH_HIST=$home/.bash_history
BACKUP_DIR=$home/.bash_history.d
BACKUP="${BACKUP_DIR}/.bash_history.$(date +%Y%m%d)"

backup()
{
    mkdir -p "$BACKUP_DIR"

    # file already exist    (need a .gz extension there since the backup file is compressed by gzip)
    # if $1 == --force, we skip this check
    if [[ -f "$BACKUP.gz" && "$1" != "--force" ]]; then
        echo "backup file already exist: $BACKUP.gz"
        exit 0
    fi

    if [[ "$1" == "--force" ]]; then
        rm "$BACKUP.gz"
    fi

    cp "$BASH_HIST" "$BACKUP"
    gzip "$BACKUP"

    # only make 30 copies
    if [[ $(ls "$BACKUP_DIR/.bash_history"* | wc -l) -ge 30 ]]; then
        ls -t "$BACKUP_DIR/.bash_history"* | tail -n+30 | \
        while read f; do
            echo removing $f
            rm "$f"
        done
    fi
}

restore()
{
    file="$1"
    if [ -z "$file" ]; then
        file=$(ls $BACKUP_DIR/.bash_history.* -rt1 | tail -n1)
    fi
    if ! [ -e "$file" ]; then
        echo file does not exist
        exit 1
    fi

    echo "Source file: $file"
    read -p "Are you sure you want to restore your bash history? [y/N] " ans

    case $ans in
        y)
            ;&
        Y)
            ;;
        *)
            exit 0;
            ;;
    esac

    cp "$file" /tmp/.bash_history.gz
    gunzip /tmp/.bash_history.gz
    rm $HOME/.bash_history
    mv /tmp/.bash_history $HOME
}



if [[ $1 == "--restore" ]]; then
    restore $2
elif [[ $1 == "--force-backup" ]]; then
    backup --force
else
    backup
fi
