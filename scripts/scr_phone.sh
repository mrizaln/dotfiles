#!/bin/bash

adb start-server
ip='192.168.100.3'
echo "is this the correct ip of the device? $ip (y/n)"
read ans
if [ "$ans" = "n" ]; then
    echo -n "input the correct ip address: "
    read ip
fi

if [ $(adb connect "$ip:5555" | tee /dev/tty | grep -E 'refused' | wc -l) != 0 ]; then
  echo "try connecting it from usb first"
  exit 1
elif [ $(adb connect "$ip:5555" | tee /dev/tty | grep -iE 'no route' | wc -l) != 0 ]; then
  echo "try connecting your device in the same network as your pc"
  exit 1
elif [ $(adb connect "$ip:5555" | tee /dev/tty | grep -iE 'timed out' | wc -l) != 0 ]; then
  echo "device inactive"
  exit 1
fi

echo 'video options: <with audio? (y/n)> <bitrate> <max height and width> <max fps> <additional options>'
echo 'note: audio only works if only one android device connected'
read waudio bit size fps add

frps="--max-fps $fps"
msize="-m$size"
bitrate="-b${bit}M"

if [ "$waudio" = "y" ]; then
    gnome-terminal -x bash -c "/opt/sndcpy/sndcpy_modified";
fi

if [ "$fps" = "" ]; then
    frps=''
fi
if [ "$size" = "" ]; then
    msize=""
fi
if [ "$bit" = "" ]; then
    bitrate=""
fi

scrcpy -s "$ip:5555" $bitrate $msize $frps $add

