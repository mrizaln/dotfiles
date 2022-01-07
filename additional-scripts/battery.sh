#!/bin/sh

# thresholds
notify="30"
warn="20"
shutoff="10"

# calculate charge
count=$(acpi -b | wc -l)
sum=$(acpi -b | egrep -o '[0-9]{1,3}%' | tr -d '%' | xargs -I% echo -n '+%')
charge=$(( sum / count ))

discharging() {
 acpi -b | grep 'Discharging' > /dev/null
 return $?
}

exitoncharge() {
  if ! discharging; then exit 0; fi
}

countdown() {
  notify-send "Battery low! Will shutdown in 30s." -u critical
  sleep 10
  exitoncharge
  notify-send "Battery low! Will shutdown in 20s." -u critical
  sleep 10
  exitoncharge
  notify-send "SHUTDOWN IN 10s" -u critical
  sleep 5
  exitoncharge
  notify-send "SHUTDOWN IN 5s" -u critical
  sleep 5
  exitoncharge
  systemctl hibernate
}


exitoncharge

if [ $charge -le $shutoff ]; then
  countdown
elif [ $charge -le $warn ]; then
  notify-send "Battery is getting low: $charge%" -u critical
elif [ $charge -le $notify ]; then
  notify-send "Battery is getting low: $charge%"
fi

