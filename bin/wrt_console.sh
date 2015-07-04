#!/bin/bash
# short executable to get the screen command started for the tty.usb
# connection in the dev folder
target=$(ls /dev | grep tty.usb)

echo "target before if is $target"

if [[ -n target  ]]; then 
	target="/dev/$target"
else
	echo "No tty.usb option in /dev folder"
	exit 1
fi

echo "Launching screen for $target at 115200 baud"

screen $target 115200

