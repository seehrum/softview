#!/bin/bash

# Exit script on command failure or when using undefined variables
set -euo pipefail

# Function to check required dependencies
check_dependencies() {
    local missing_dependencies=()
    local dependencies=(xrandr rofi redshift)

    for dep in "${dependencies[@]}"; do
        if ! type "$dep" &>/dev/null; then
            missing_dependencies+=("$dep is not installed")
        fi
    done

    if (( ${#missing_dependencies[@]} != 0 )); then
        printf "Error: missing dependencies:\n%s\n" "${missing_dependencies[@]}" >&2
        exit 1
    fi
}

# Function to select monitor
select_monitor() {
    local monitors
    monitors=$(xrandr --query | grep " connected" | cut -d" " -f1)
    if [ "$(echo "$monitors" | wc -l)" -gt 1 ]; then
        echo "$monitors" | rofi -dmenu -p "Select Monitor:" -config /usr/share/rofi/themes/Arc-Dark.rasi
    else
        echo "$monitors"
    fi
}

# Function to list monitor configuration options
list_options() {
    echo "Reset: xrandr --output $1 --set CTM '0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1' ; redshift -x"
    echo "GrayScale: xrandr --output $1 --set CTM '1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0'"
    echo "Brightness 0.5: xrandr --output $1 --brightness 0.5"
    echo "RedShift 1: redshift -oP -O 4500 -b 0.5"
    echo "RedShift 2: redshift -oP -O 3300 -b 0.7"
    echo "RedShift 3: redshift -oP -O 10000 -g .1:1:.1"
    echo "RedShift 4: redshift -oP -O 1000 -g 1:1.1:1"
}

# Main execution flow
check_dependencies

monitor=$(select_monitor)
if [[ -z "$monitor" ]]; then
    echo "No monitor selected, exiting." >&2
    exit 0
fi

selected_option=$(list_options "$monitor" | rofi -dmenu -p "Select configuration:" -config /usr/share/rofi/themes/Arc-Dark.rasi)
if [[ -z "$selected_option" ]]; then
    echo "No option selected, exiting." >&2
    exit 0
fi

command=$(echo "$selected_option" | cut -d':' -f2- | xargs)
if [[ -z "$command" ]]; then
    echo "Invalid command, exiting." >&2
    exit 1
fi

# Execute the command securely
eval "$command"
