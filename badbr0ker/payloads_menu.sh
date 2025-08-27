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
echo "1) Br0ker / Br0ker (unenrollment up to kernver 5) By OlyB. Ported to BadRecovery by HarryJarry1"
echo "2) SH1mmer caliginosity.sh / Revert all changes made by sh1mmer or badsh1mmer (reenroll + more)"
echo "3) Icarus / Icarus (unenrollment up to r129, by writable)"
echo "4) MrChromebox Firmware Utility"
echo "5) Reset Kernel Rollback version / sets kernver to 0x00010001 (factory defaults)"
echo "s) Shell"
echo "c) Credits"
echo "e) Exit and reboot"

echo -n "Enter a number: "
read choice

if [ "$choice" = "1" ]; then
    /bin/sh "$PAYLOAD_DIR/badbr0ker.sh"
elif [ "$choice" = "2" ]; then
    /bin/sh "$PAYLOAD_DIR/caliginosity.sh" # someone fix mrchromebox and icarus if they're broken, I just copy pasted from the sh1mmer repo
elif [ "$choice" = "3"]; then
    /bin/sh "$PAYLOAD_DIR/icarus.sh"
elif [ "$choice" = "4"]; then
    /bin/sh "$PAYLOAD_DIR/mrchromebox.sh"
elif [ "$choice" = "5"]; then
    /bin/sh "$PAYLOAD_DIR/reset-kern-rollback.sh"
elif [ "$choice" = "s"]; then
    /bin/sh
    sleep infinity
elif [ "$choice" = "c"]; then
    echo "-----BadSH1mmer-----"
    echo "OlyB: creating BadRecovery, and Br0ker, + helping with scripts and some other stuff too"
    echo "HarryJarry1: creating BadBr0ker, finding the vpd vulnerability"
    echo "Lxrd: Sh1ttyOOBE"
    # i gtg ill add others later
elif [ "$choice" = "e" ]; then
    echo "Rebooting..."
	reboot
else
    echo "Invalid choice."
fi
