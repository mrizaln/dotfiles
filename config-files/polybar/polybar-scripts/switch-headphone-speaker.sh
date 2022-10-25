#!/usr/bin/env bash

state=$(pactl list sinks | grep Active | cut -d: -f2-)

# remove leading whitespace characters
state="${state#"${state%%[![:space:]]*}"}"

case "$state" in
    analog-output-speaker)
	pactl set-sink-port 0 analog-output-headphones
	;;
    analog-output-headphones)
	pactl set-sink-port 0 analog-output-speaker
	;;
esac
