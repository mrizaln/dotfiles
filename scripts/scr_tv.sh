#!/bin/bash

adb start-server
ip='192.168.100.4'
echo "is this the correct ip of the device? $ip (y/n)"
read res
if [ "$res" = "n" ]; then
    echo "input the correct ip address:"
    read ip
fi

adb connect "$ip:5555"

echo 'video options: <with audio? (y/n)> <bitrate> <max height and width> <addtional options>'
echo 'note: audio only works if only one android device connected'
read waudio bit size add

msize="-m$size"
bitrate="-b${bit}M"

if [ "$waudio" = "y" ]; then
    gnome-terminal -x bash -c "./packages/sndcpy/sndcpy_modified";
fi

if [ "$size" = "" ]; then
    msize=""
fi
if [ "$bit" = "" ]; then
    bitrate=""
fi
scrcpy -s "$ip:5555" $bitrate $msize $add
