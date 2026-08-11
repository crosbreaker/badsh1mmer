#!/bin/sh
stateful_mount="/stateful"
metadata_mount="/metadata"
fail(){
	printf "$1\n"
	printf "exiting...\n"
	exit
}

proto_gaming(){
	printf '\012\177\012\043unencrypted/../../../run/vpd/ro.txt\020\124\032\126\022\124re_enrollment_key="'"$(hexdump -e '1/1 "%02x"' -v -n 32 /dev/urandom)"'"' | base64 -w0
}

get_fixed_dst_drive() {
	local dev
	if [ -z "${DEFAULT_ROOTDEV}" ]; then
		for dev in /sys/block/sd* /sys/block/mmcblk*; do
			if [ ! -d "${dev}" ] || [ "$(cat "${dev}/removable")" = 1 ] || [ "$(cat "${dev}/size")" -lt 2097152 ]; then
				continue
			fi
			if [ -f "${dev}/device/type" ]; then
				case "$(cat "${dev}/device/type")" in
				SD*)
					continue;
					;;
				esac
			fi
			DEFAULT_ROOTDEV="{$dev}"
		done
	fi
	if [ -z "${DEFAULT_ROOTDEV}" ]; then
		dev=""
	else
		dev="/dev/$(basename ${DEFAULT_ROOTDEV})"
		if [ ! -b "${dev}" ]; then
			dev=""
		fi
	fi
	echo "${dev}"
}

wipeandmountstate(){
	vgchange -ay >/dev/null 2>&1
    volgroup=$(vgscan | grep "Found volume group" | awk '{print $4}' | tr -d '"')
	if [ -b "/dev/$volgroup/unencrypted" ]; then
		echo "Debug: Found volume group: $volgroup"
		echo
		mkdir -p "$stateful_mount"
		echo "Wiping stateful..."
		mkfs.ext4 -F /dev/$volgroup/unencrypted >/dev/null 2>&1
        mount /dev/$volgroup/unencrypted "$stateful_mount"
	else
		echo "lvm fail, falling back on p1"
		mkdir -p "$stateful_mount"
		echo "Wiping stateful..."
		mkfs.ext4 -F "${intdis_prefix}1" || fail "no stateful could be found/wiped"
        mount "$intdis_prefix"1 "$stateful_mount"
	fi
}

checkcurrentstate(){
    echo "Checking current state..."
	echo
    mkdir "$metadata_mount"
    mount "${intdis_prefix}11" "$metadata_mount" >/dev/null 2>&1 || part1
	part2
}

part1(){
	echo "Starting part 1"
	echo
    wipeandmountstate
    mkdir -p "$stateful_mount"/unencrypted
    touch "$stateful_mount"/unencrypted/.default_key_stateful_migration
    crossystem disable_dev_request=1
    umount "$stateful_mount"
    echo "Ready to reboot. Please re-run this script after the update finishes."
	echo "It may update multiple times, you need to wait for all of them to finish."
	echo
	echo "Run reboot -f to easily reboot"
	exit 0
}

part2(){
	echo "Starting part 2"
	chattr -i "$metadata_mount"/preseeder.proto >/dev/null 2>&1
	rm -f "$metadata_mount"/preseeder.proto
    proto_gaming > "$metadata_mount"/preseeder.proto
    chattr +i "$metadata_mount"/preseeder.proto 
    sync
    umount "$metadata_mount"
    sync
    crossystem disable_dev_request=1
    echo "Ready for another reboot. Go through setup, you will be unenrolled."
	echo
	echo "Run reboot -f to easily reboot"
	exit 0
}

main(){
    . /usr/sbin/write_gpt.sh
    load_base_vars
    intdis=$(get_fixed_dst_drive)
	if echo "$intdis" | grep -q '[0-9]$'; then
		intdis_prefix="$intdis"p
	else
		intdis_prefix="$intdis"
	fi
	#below is code to prevent this from being run without rebooting in between (part 1 and 2 in the same boot)
	if [ -f /run/protowriterunthisboot ]; then
         echo "You have run protowrite this boot."
		 echo "Please reboot and try again"
		 exit 1
    fi
	touch /run/protowriterunthisboot
    clear
	echo "Protowrite by crossystem/emerywi"
	echo
	echo "Unenrollment on v135-v145"
	echo
	echo "Script written by con"
	echo
    checkcurrentstate
}

main
