#!/bin/bash

#checking kernel version before updating
#echo 'checking your kernel version...'
#ker_bef=$(uname -r)
#echo "your kernel version before update is: $ker_bef"
#echo ''
echo "updating..."
echo ''

#updating sequence
sudo apt update; echo
apt list --upgradable; echo
sleep 3
sudo apt upgrade; echo
sudo apt autoremove; echo

echo 'updating sequence completed'
echo ''
#echo 'checking your current kernel version...'
#ker_aft=$(uname -r)
#echo "your kernel version before update is: $ker_bef"
#echo "your kernel version after update is : $ker_aft"

#if [ "$ker_bef" != "$ker_aft" ]; then
#    echo "your kernel has been updated, commencing installing additional software"
#    echo ''
#    sudo ./after_kernel_update
#    echo 'exiting'
#else
#    echo "your kenel hasn't changed"
#    echo 'exiting'
#fi
