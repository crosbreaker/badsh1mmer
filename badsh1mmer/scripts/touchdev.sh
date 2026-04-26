#!/bin/sh
get_internal() {
  # get_largest_cros_blockdev does not work in BadApple.
  local ROOTDEV_LIST=$(cgpt find -t rootfs) # thanks stella
  if [ -z "$ROOTDEV_LIST" ]; then
    fail "could not parse for rootdev devices. this should not have happened."
  fi
  local device_type=$(echo "$ROOTDEV_LIST" | grep -oE 'blk0|blk1||nvme|sda' | head -n 1)
  case $device_type in
  "blk0")
    intdis=/dev/mmcblk0
      intdis_prefix="p"
    break
    ;;
  "blk1")
    intdis=/dev/mmcblk1
      intdis_prefix="p"
    break
    ;;
  "nvme")
    intdis=/dev/nvme0
      intdis_prefix="n"
    break
    ;;
  "sda")
    intdis=/dev/sda
      intdis_prefix=""
    break
    ;;
  *)
    fail "an unknown error occured. this should not have happened."
    ;;
  esac
}
mountlvm(){
  mkdir -p /localroot 
	mount ${intdis_prefix}$(get_booted_rootnum) /localroot -o ro
	# yes i know below is really inefficient, but the other way isnt work and i cant understand why
	sync # call just in case?
	mount --bind /dev /localroot/dev
	mount --bind /proc /localroot/proc
	mount --bind /sys /localroot/sys
	mount --bind /run /localroot/run
	chroot /localroot /sbin/vgchange -ay
  volgroup=$(chroot /localroot /sbin/vgscan | grep "Found volume group" | awk '{print $4}' | tr -d '"')
	if [ -b "/dev/$volgroup/unencrypted" ]; then
		echo "found volume group: $volgroup"
		mkdir "$stateful_mount"
		chroot /localroot /sbin/mkfs.ext4 -F /dev/$volgroup/unencrypted
    mount /dev/$volgroup/unencrypted "$stateful_mount"
	else
		echo "lvm fail, falling back on p1"
		chroot /localroot /sbin/mkfs.ext4 -F "$intdis_prefix"1 || fail "no stateful could be found/wiped"
    mount "$intdis_prefix"1 "$stateful_mount"
	fi
}
get_internal
mount "$intdis$intdis_prefix"1 /stateful || mountlvm
touch /stateful/.developer_mode
umount /stateful
echo "5 minute wait skipped"
sleep 2
