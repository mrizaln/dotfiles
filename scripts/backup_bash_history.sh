#!/usr/bin/env bash

BASH_HIST=~/.bash_history
BACKUP_DIR=~/.bash_history.d
BACKUP="${BACKUP_DIR}/.bash_history.$(date +%Y%m%d)"

mkdir -p "$BACKUP_DIR"

# file already exist    (need a .gz extension there since the backup file is compressed by gzip)
if [[ -f "$BACKUP.gz" ]]; then
    exit 0
fi

cp "$BASH_HIST" "$BACKUP"
gzip "$BACKUP"

# only make 30 copies
if [[ $(ls "$BACKUP_DIR/.bash_history"* | wc -l) -gt 30 ]]; then
    ls "$BACKUP_DIR/.bash_history"* | tail +30 | \
    while read f; do
        echo removing $f
        rm "$f"
    done
fi
