#!/bin/bash

if [ -f /usb/usr/sbin/scripts/mrchromebox.tar.gz ]; then
	echo "extracting mrchromebox.tar.gz"
	mkdir /tmp/mrchromebox
	tar -xf /usb/usr/sbin/scripts/mrchromebox.tar.gz -C /tmp/mrchromebox
else
	echo "mrchromebox.tar.gz not found!" >&2
	exit 1
fi

clear
cd /tmp/mrchromebox
chmod +x /tmp/mrchromebox/firmware-util.sh
./tmp/mrchromebox/firmware-util.sh || :

rm -rf /tmp/mrchromebox
