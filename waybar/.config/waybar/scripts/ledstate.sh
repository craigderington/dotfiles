#!/bin/bash
num_lock_led="/sys/class/leds/input3::numlock/brightness"

output_json() {
    local text="$1"
    local active="$2"
    if [ "$active" = "1" ]; then
        echo "{\"text\": \"$text\", \"class\": \"active\"}"
    else
        echo "{\"text\": \"$text\", \"class\": \"inactive\"}"
    fi
}

numlock_state=$(cat "$num_lock_led")
output_json "numlock" "$numlock_state"
