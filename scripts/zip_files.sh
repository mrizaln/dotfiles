#!/bin/env bash

filename=$(yad --entry --entry-label="Filename:")

if [[ "$filename" == "" ]]; then exit 0; fi

filename="${filename//.zip/}.zip"

zip "$filename" "$@"
