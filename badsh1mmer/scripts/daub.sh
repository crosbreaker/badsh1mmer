 #!/bin/sh
fail(){
	printf "$1\n"
	printf "exiting...\n"
	exit
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
	mkdir -p /localroot /stateful
	mount "$intdis_prefix$(get_booted_rootnum)" /localroot -o ro
	for rootdir in dev proc run sys; do
		mount --bindable "${rootdir}" /localroot/"${rootdir}"
	done
	clear
	menu
    echo
    read -p "Would you like to disable developer mode (skips beep) (Y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
	    crossystem disable_dev_request=1
    fi
    echo
    echo
    echo "Done! Run reboot -f to reboot."
}
menu() {
	echo "DAUB by crosbreaker, orginally found by Hannah. Script by Con & Mariah"
	echo "https://crosbreaker.dev"
	echo
	echo "(1) Fix DAUB bootlooping"
	echo "(2) Setup DAUB"
	echo "(3) Exit Utility"
	# add undoing daub soon
	read -p "" -n 1 -r
	echo
	if [[ $REPLY =~ ^[1]$ ]]; then
		echo "Fixing DAUB bootloop via wiping stateful"
		wipestate
	elif [[ $REPLY =~ ^[2]$ ]]; then
		echo "Setting up DAUB..."
		wipestate
		chroot /localroot /sbin/cgpt add "$intdis" -i $(get_booted_kernnum) -P 10 -T 5 -S 1
    		(
        		echo "d"
        		echo "$(opposite_num $(get_booted_kernnum))"
        		echo "d"
        		echo "$(opposite_num $(get_booted_rootnum))"
        		echo "w" 
    		) | chroot /localroot /sbin/fdisk "$intdis"
		for rootdir in dev proc run sys; do
			umount /localroot/"${rootdir}"
		done
		umount /localroot
		rmdir /localroot
	elif [[ $REPLY =~ ^[3]$ ]]; then
		exit 0
	else
	    clear
		echo "invalid option"
		menu
	fi
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
wipestate(){
    chroot /localroot /sbin/vgchange -ay #activate all volume groups
    volgroup=$(chroot /localroot /sbin/vgscan | grep "Found volume group" | awk '{print $4}' | tr -d '"')
	if [ -b "/dev/$volgroup/unencrypted" ]; then
		echo "found volume group: $volgroup"
		chroot /localroot /sbin/mkfs.ext4 -F /dev/$volgroup/unencrypted
	else
		echo "lvm fail, falling back on p1"
		chroot /localroot /sbin/mkfs.ext4 -F "$intdis_prefix"1
	fi
}
get_booted_kernnum() {
    if $(expr $(cgpt show -n "$intdis" -i 2 -P) > $(cgpt show -n "$intdis" -i 4 -P)); then
        echo -n 2
    else
        echo -n 4
    fi
}
get_booted_rootnum() {
	expr $(get_booted_kernnum) + 1
}
opposite_num() {
    if [ "$1" == "2" ]; then
        echo -n 4
    elif [ "$1" == "4" ]; then
        echo -n 2
    elif [ "$1" == "3" ]; then
        echo -n 5
    elif [ "$1" == "5" ]; then
        echo -n 3
    else
        return 1
    fi
}
main
