#!/bin/sh
#https://github.com/BinBashBanana/badrecovery
# spinner is always the 2nd /bin/sh
spinner_pid=$(pgrep /bin/sh | head -n 2 | tail -n 1)
kill -9 "$spinner_pid"
pkill -9 tail
sleep 0.1

HAS_FRECON=0
if pgrep frecon >/dev/null 2>&1; then
	HAS_FRECON=1
	# restart frecon to make VT1 background black
	exec </dev/null >/dev/null 2>&1
	pkill -9 frecon || :
	rm -rf /run/frecon
	frecon-lite --enable-vt1 --daemon --no-login --enable-vts --pre-create-vts --num-vts=4 --enable-gfx
	until [ -e /run/frecon/vt0 ]; do
		sleep 0.1
	done
	exec </run/frecon/vt0 >/run/frecon/vt0 2>&1
	# note: switchvt OSC code only works on 105+
	printf "\033]switchvt:0\a\033]input:off\a"
	echo "Press CTRL+ALT+F1 if you're seeing this" | tee /run/frecon/vt1 /run/frecon/vt2 >/run/frecon/vt3
else
	exec </dev/tty1 >/dev/tty1 2>&1
	chvt 1
	stty -echo
	echo "Press CTRL+ALT+F1 if you're seeing this" | tee /dev/tty2 /dev/tty3 >/dev/tty4
fi

printf "\033[?25l\033[2J\033[H"
echo "Creating RW /tmp"
mount -t tmpfs -o rw,exec,size=50M tmpfs /tmp
echo "...$?"

# These shouldn't are not needed
# vpd -i RW_VPD -s block_devmode=0 >/dev/null 2>&1
# echo "Modifying VPD (check_enrollment=0 block_devmode=0)"
# echo "Note: the vpd utility acts really weird in recovery, but it actually writes the values ok."
# vpd -i RW_VPD -s check_enrollment=0 -s block_devmode=0 >/dev/null 2>&1
# echo "...$?"

# echo "Setting block_devmode=0 in crossystem"
# crossystem block_devmode=0
# echo "...$?"

if [ $HAS_FRECON -eq 1 ]; then
	printf "\033]input:on\a"
else
	stty echo
fi
echo "launching payloads_menu.sh"
sh /usb/usr/sbin/payloads_menu.sh
printf "\033[?25h"
while :; do sh; done
