#!/bin/bash

echo 'with audio? (y/n)'

read aud

if [ "$aud" = "n" ]; then
    ffmpeg -f x11grab -r 15 -s 1366x768 -i :0.0+0,0 ~/Videos/$(date +%F_%H-%M-%S).mkv

elif [ "$aud" = "y" ]; then
    ffmpeg -f x11grab -s 1366x768 -i :0.0+0,0 -f alsa -i hw:1 ~/Videos/$(date +%F_%H-%M-%S).mkv

else
    ffmpeg
fi
