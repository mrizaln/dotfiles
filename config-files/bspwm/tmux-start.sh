#!/usr/bin/env bash

echo "Disk Usage:"
~/.local/bin/check_disk_usage.py
echo -e "\nBasic Information:"
neofetch
