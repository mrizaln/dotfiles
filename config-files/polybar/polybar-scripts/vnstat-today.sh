#!/bin/bash

usage=$(vnstat | grep today | cut -d/ -f3 | tr -s ' ' | cut -d\  -f2-)
echo "[${usage%% }]"
