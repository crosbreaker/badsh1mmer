#!/bin/bash

if [ -f /usb/usr/sbin/scripts/mrchromebox.tar.gz ]; then
	echo "extracting mrchromebox.tar.gz"
	mkdir -p /mrchromebox
	tar -xf /usb/usr/sbin/scripts/mrchromebox.tar.gz -C /mrchromebox
else
	echo "mrchromebox.tar.gz not found!" >&2
	exit 1
fi

clear
chmod +x /mrchromebox/firmware-util.sh
mkdir /localroot
mount /dev/mmcblk0p3 /localroot -o ro # TODO: add int disk determination
mount --bind /dev /localroot/dev
mount --bind /sys /localroot/sys
mount --bind /mrchromebox /localroot/mnt/stateful_partition # use stateful because it is always clean
chroot /localroot /mnt/stateful_partition/mrchromebox/firmware-util.sh
echo "cleaning up..."
rm -rf /mrchromebox
umount /localroot/dev
umount /localroot/mnt/stateful_partition
umount /localroot
rmdir /localroot
