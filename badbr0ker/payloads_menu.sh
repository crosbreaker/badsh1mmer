#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=${SCRIPT_DIR:-"."}

set -eE

SCRIPT_DATE="[2025-08-26]"
PAYLOAD_DIR=/usb/usr/sbin/scripts
RECOVERY_KEY_LIST="$PAYLOAD_DIR"/short_recovery_keys.txt

MNT=
TMPFILE=

fail() {
	printf "%b\n" "$*" >&2
	exit 1
}
 # ill add fail stuff later ima test it rn to make sure its working.
echo "Select a script to run:"
echo "1) badbr0ker.sh"
echo "2) test function | remove later."
echo "e) exit and reboot"

echo -n "Enter a number: "
read choice

if [ "$choice" = "1" ]; then
    sh "$PAYLOAD_DIR/badbr0ker.sh"
elif [ "$choice" = "2" ]; then
    echo "testing..."
elif [ "$choice" = "e" ]; then
    echo "Rebooting..."
	reboot
else
    echo "Invalid choice."
fi
