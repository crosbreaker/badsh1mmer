#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=${SCRIPT_DIR:-"."}

set -eE

SCRIPT_DATE="[2025-08-26]"
SCRIPT_BUILD="0.0.1 BETA"
PAYLOAD_DIR=/usb/usr/sbin/scripts
RECOVERY_KEY_LIST="$PAYLOAD_DIR"/short_recovery_keys.txt

MNT=
TMPFILE=

fail() {
	printf "%b\n" "$*" >&2
	exit 1
}

clear

echo "===============================================BADSH1MMER========================================"
echo "                                              $SCRIPT_DATE"
echo "                                             v$SCRIPT_BUILD"
echo "                                          https://crosbreaker.dev"
echo "                                  https://github.com/crosbreaker/BadSH1mmer"
echo "================================================================================================="
echo "                                         Select a script to run:"
echo "(1) Br0ker / unenrollment up to kernver 5, By OlyB. Ported to BadRecovery by HarryJarry1"
echo "(2) Caliginosity / Revert all changes made by sh1mmer or badsh1mmer (reenroll + more)"
echo "(3) Icarus / unenrollment up to r129, by writable"
echo "(4) MrChromebox Firmware Utility"
echo "(s) Shell"
echo "(c) Credits"
echo "(w) whale payload"
echo "(e) Exit and reboot"
echo ""
echo -n "> "
read choice

if [ "$choice" = "1" ]; then
    /bin/sh "$PAYLOAD_DIR/badbr0ker.sh"
	/bin/sh
 	sleep infinity
elif [ "$choice" = "2" ]; then
    /bin/sh "$PAYLOAD_DIR/caliginosity.sh" # someone fix mrchromebox and icarus if they're broken, I just copy pasted from the sh1mmer repo
 	sh /usb/usr/sbin/payloads_menu.sh
  	sleep infinity
elif [ "$choice" = "3" ]; then
    /bin/sh "$PAYLOAD_DIR/icarus.sh"
 	sh /usb/usr/sbin/payloads_menu.sh
  	sleep infinity
elif [ "$choice" = "4" ]; then
    /bin/sh "$PAYLOAD_DIR/mrchromebox.sh"
	sh /usb/usr/sbin/payloads_menu.sh
  	sleep infinity
elif [ "$choice" = "s" ]; then
	sh /usb/usr/sbin/payloads_menu.sh
    sleep infinity
elif [ "$choice" = "c" ]; then
    echo "-----BadSH1mmer-----"
    echo "OlyB: creating BadRecovery, and Br0ker, + helping with scripts and some other stuff too"
    echo "HarryJarry1: creating BadBr0ker, finding the vpd vulnerability. Also a ton of random fixes in badsh1mmer"
    echo "Lxrd: Sh1ttyOOBE"
	echo "crossjbly: Creating menu, fixing stuff"
 	echo "fanqyxl: hosting (hopefully)"
   	echo "-------------------"
	echo ""
 	echo "entering shell..."
	/bin/sh
 	sleep infinity
elif [ "$choice" = "e" ]; then
    echo "Rebooting in 3 seconds..."
	sleep 3
	reboot -f
 	echo "If you are seeing this the reboot failed, please manually reboot by hitting REFRESH and POWER at the same time."
  	echo "Or you can play around with the shell."
    /bin/sh
 	sleep infinity
elif [ "$choice" = "w" ]; then
	cat "$PAYLOAD_DIR/whale.txt"
 	sleep infinity
else
    echo "Invalid choice"
	echo "entering shell..."
 	echo ""
  	/bin/sh
   	sleep infinity
fi
