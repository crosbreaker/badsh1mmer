#!/bin/bash

if [ -f mrchromebox.tar.gz ]; then
	echo "extracting mrchromebox.tar.gz"
	mkdir /tmp/mrchromebox
	tar -xf mrchromebox.tar.gz -C /tmp/mrchromebox
else
	echo "mrchromebox.tar.gz not found!" >&2
	exit 1
fi

clear
cd /tmp/mrchromebox
chmod +x firmware-util.sh
./firmware-util.sh || :

rm -rf /tmp/mrchromebox
