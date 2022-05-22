#!/bin/bash

case $1 in
    '')
    file="`date +%F_%H-%M-%S`"
    ;;

    *)
    file="`date +%F_%H-%M-%S`.$1"
    ;;
esac

nano "$file"
copy_to_clipboard.sh "$file" content
