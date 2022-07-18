#!/usr/bin/env bash

## Terminate already running bar instances
#killall -q polybar
#
## Wait until the processes have been shut down
#while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#
#(sleep 2; polybar bar) &
##(sleep 2; polybar tray) &

killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 0.5; done

for m in $(polybar -m | cut -d: -f1); do
    MONITOR=$m polybar --reload bar 2> /dev/null &
done
