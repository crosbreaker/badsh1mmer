#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=${SCRIPT_DIR:-"."}

set -eE

SCRIPT_DATE="[2026-03-2026]"
SCRIPT_BUILD="1.2"
PAYLOAD_DIR=/usb/usr/sbin/scripts
RECOVERY_KEY_LIST="$PAYLOAD_DIR"/short_recovery_keys.txt

MNT=
TMPFILE=

fail() {
	printf "%b\n" "$*" >&2
	exit 1
}

clear
echo "IF8gICAgICAgICAgICAgICBfICAgICBfICAgICBfICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAp8IHxfXyAgIF9fIF8gIF9ffCB8X19ffCB8X18gLyB8XyBfXyBfX18gIF8gX18gX19fICAgX19fIF8gX18gCnwgJ18gXCAvIF9gIHwvIF9gIC8gX198ICdfIFx8IHwgJ18gYCBfIFx8ICdfIGAgXyBcIC8gXyBcICdfX3wKfCB8XykgfCAoX3wgfCAoX3wgXF9fIFwgfCB8IHwgfCB8IHwgfCB8IHwgfCB8IHwgfCB8ICBfXy8gfCAgIAp8Xy5fXy8gXF9fLF98XF9fLF98X19fL198IHxffF98X3wgfF98IHxffF98IHxffCB8X3xcX19ffF98ICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA=" | base64 -d
echo "" # fix display
echo "$SCRIPT_DATE" # \n so it displays better
echo "v$SCRIPT_BUILD"
echo "https://crosbreaker.com"
echo "https://github.com/crosbreaker/BadSH1mmer"
echo ""
echo "(1) Br0ker / unenrollment up to kernver 5, By OlyB. Ported to BadRecovery by HarryJarry1"
echo "(2) Caliginosity / Revert all changes made by sh1mmer or badsh1mmer (reenroll + more)"
echo "(3) Icarus / unenrollment up to r129, by writable"
echo "(4) MrChromebox Firmware Utility"
echo "(5) Touch .developer_mode (skip 5 minute delay)"
echo "(6) Daub / Originally found by Hannah, script by con/mariah carey"
echo "(7) Quicksilver / Unenrollment up to kernver 6, by emerwyi. Script by mariah carey"
echo "(8) protowrite / Unenrollment up to kernver 7, by emerwyi. Script by con"
echo "(9) print device information to screen/to USB (stable device secret, etc)"
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
elif [ "$choice" = "5" ]; then
    /bin/sh "$PAYLOAD_DIR/touchdev.sh"
        sh /usb/usr/sbin/payloads_menu.sh
        sleep infinity
elif [ "$choice" = "6" ]; then
    /bin/sh "$PAYLOAD_DIR/daub.sh"
        sh /usb/usr/sbin/payloads_menu.sh
        sleep infinity
elif [ "$choice" = "badrecovery" ]; then # this is just for debugging.
    /bin/sh "$PAYLOAD_DIR/badrecovery_debug.sh"
        sh /usb/usr/sbin/payloads_menu.sh
        sleep infinity
elif [ "$choice" = "7" ]; then
    /bin/sh "$PAYLOAD_DIR/quicksilver.sh"
        sh /usb/usr/sbin/payloads_menu.sh
        sleep infinity
elif [ "$choice" = "8" ]; then
    	/bin/sh "$PAYLOAD_DIR/protowrite.sh"
        sh /usb/usr/sbin/payloads_menu.sh
        sleep infinity
elif [ "$choice" = "9" ]; then
		vpd -i RW_VPD -l --no-cache
		vpd -l --no-cache
		driveletter=$(mount | grep "/usb type ext4" | cut -c8)
		echo "Debug: drive letter is $driveletter"
		mkfs.vfat /dev/sd"$driveletter"1
		mount /dev/sd"$driveletter"1 /mnt/empty
		crossystem --all > /mnt/empty/devinfo.txt
		flashrom -p internal --wp-status >> /mnt/empty/devinfo.txt
		vpd -i RW_VPD -l --no-cache >> /mnt/empty/devinfo.txt
		vpd -l --no-cache >> /mnt/empty/devinfo.txt
		umount /mnt/empty
		sync
		echo "These are also stored to the USB drive. You may view them in devinfo.txt"
		/bin/sh
    	sleep infinity
elif [ "$choice" = "s" ]; then
	/bin/sh #shut up! its fixed now :whale:
	sh /usb/usr/sbin/payloads_menu.sh
    sleep infinity
elif [ "$choice" = "c" ]; then
    echo "-----BadSH1mmer-----"
    echo "OlyB: creating BadRecovery, and Br0ker, + helping with scripts and some other stuff too"
    echo "HarryJarry1: Active maintainer"
    echo "Lxrd: Sh1ttyOOBE, Sh1ttyExec"
	echo "crossjbly/xz8f: Creating menu, fixing stuff"
 	echo "fanqyxl: hosting (hopefully)"
	echo "Hannah: finding DAUB"
	echo "Mariah carey: making the daub.sh script"
	echo "emerwyi: quicksilver, protowrite"
	# codenerd you're not fun :rage: bring back fanxql injection!!!
	# echo "fanxql: being tuff, fanxql injection"
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
 	/bin/sh
else
    echo "Invalid choice"
	echo "entering shell..."
 	echo ""
  	/bin/sh
   	sleep infinity
fi
