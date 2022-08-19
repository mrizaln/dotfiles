#!/bin/env bash

if [[ "$1" == "--unzip" ]]; then
        notify-send "unzipping $2"
        unzip "$2"
        notify-send "unzip completed"
        exit 0
fi

filename=$(yad --entry --entry-label="Filename:")

if [[ "$filename" == "" ]]; then exit 0; fi

filename="${filename//.zip/}.zip"

zip -r "$filename" "$@"
