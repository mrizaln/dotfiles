#!/bin/env bash

if [[ "$1" == "--unzip" ]]; then
    if [[ ${#@} -le 2 ]]; then
        notify-send "unzipping $2"
    else
        notify-send "unzipping file(s)"
    fi
    unzip "${@:2}"
    notify-send "unzip completed"
    exit 0
fi

filename=$(yad --entry --entry-label="Filename:")

if [[ "$filename" == "" ]]; then exit 0; fi

filename="${filename//.zip/}.zip"

echo "zipping into $filename"
zip -r "$filename" "$@"
