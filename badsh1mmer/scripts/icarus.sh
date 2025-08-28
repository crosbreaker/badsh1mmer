#!/bin/sh

# written by appleflyer

mexit(){
	printf "$1\n"
	printf "exiting...\n"
	exit
}

get_stateful() {
	# get_largest_cros_blockdev does not work in BadApple.
	local ROOTDEV_LIST=$(cgpt find -t rootfs) # thanks stella
	if [ -z "$ROOTDEV_LIST" ]; then
		mexit "could not parse for rootdev devices. this should not have happened."
	fi
	local device_type=$(echo "$ROOTDEV_LIST" | grep -oE 'mmc|nvme|sda' | head -n 1)
	case $device_type in
	"mmc")
		stateful=/dev/mmcblk0p1
		break
		;;
	"nvme")
		stateful=/dev/nvme0n1
		break
		;;
	"sda")
		stateful=/dev/sda1
		break
		;;
	*)
		mexit "an unknown error occured. this should not have happened."
		;;
	esac
}

does_out_exist() {
    [ ! -d "/usb/usr/sbin/scripts/PKIMetadata" ] && mexit "out directory not in usb stick. this should NOT happen."
}

wipe_stateful(){
    mkfs.ext4 -F "$stateful" || mexit "failed to wipe stateful, what happened?"
    mount "$stateful" /stateful || mexit "failed to mount, what happened?"
    mkdir -p /stateful/unencrypted
}

move_out_to_stateful(){
    cp /usb/usr/sbin/PKIMetadata /stateful/unencrypted/ -rvf
    chown 1000 /stateful/unencrypted/PKIMetadata -R
}

main() {
        mkdir /stateful #idk if this is in badrecovery or not
	does_out_exist
	get_stateful
	wipe_stateful
	move_out_to_stateful
	umount /stateful
	crossystem disable_dev_request=1 || mexit "how did this shit even fail??"
	read -p "payload finished! enter to view payloads. you will boot into verified mode."
	echo "should not have reached here. error occured."
	exit
}

main
