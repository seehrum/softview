#!/bin/bash

# Check dependencies
check_dependencies() {
    local dependencies=(xrandr rofi redshift)
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: Required command '$cmd' is not installed." >&2
            exit 1
        fi
    done
}

check_dependencies

# Lists monitors and allows the user to choose one if there is more than one
monitors=$(xrandr --query | grep " connected" | cut -d" " -f1)
if [ "$(echo "$monitors" | wc -l)" -gt 1 ]; then
    monitor=$(echo "$monitors" | rofi -dmenu -p "Select Monitor:" -config /usr/share/rofi/themes/Arc-Dark.rasi)
else
    monitor=$monitors
fi

# Ensures that a monitor has been selected
test -n "$monitor" || { echo "No monitor selected, exiting."; exit 0; }

# Sets the monitor configuration options
list_options() {
    echo "Reset : xrandr --output $monitor --set CTM '0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1' ; redshift -x"
    echo "GrayScale : xrandr --output $monitor --set CTM '1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0,1431655765,0'"
    echo "Brightness 0.5 : xrandr --output $monitor --brightness 0.5"
    echo "RedShift 1 : redshift -oP -O 4500 -b 0.5"
    echo "RedShift 2 : redshift -oP -O 3300 -b 0.7"
    echo "RedShift 3 : redshift -oP -O 10000 -g .1:1:.1"
    echo "RedShift 4 : redshift -oP -O 1000 -g 1:1.1:1"
}

# Show the list of options with rofi and execute the selection directly
selected_option=$(list_options | rofi -dmenu -p "Select configuration:" -config /usr/share/rofi/themes/Arc-Dark.rasi)

# Checks if an option has been selected
test -n "$selected_option" || { echo "No option selected, exiting."; exit 0; }

# Extracts only the command from the selected result
command=$(echo "$selected_option" | cut -d':' -f2- | xargs)

# Execute the selected command
if [ -n "$command" ]; then
    bash -c "$command"
else
    echo "Invalid command, exiting."
    exit 1
fi
