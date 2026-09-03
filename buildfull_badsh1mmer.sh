#!/bin/bash
# simple passthrough script + downloading a 129 image
board=$1
board=$(echo "$board" | tr '[:upper:]' '[:lower:]') # mw thingy needs lowercase board names
if ! [ -z $1 ]; then
	recoveryver=129
else
  echo "Usage: sudo bash ./buildfull_badsh1mmer.sh <board>"
  exit 1
fi
if [ "$board" = "rauru" ]; then
    recoveryver=137
fi 
fail() {
    printf "%b\n" "$1" >&2
    printf "error occurred\n" >&2
    exit 1
}
findimage(){ # Taken from murkmod
	echo "finding recovery image for $board $recoveryver"
	local mercury_data_url="https://cdn.jsdelivr.net/gh/crosbreaker/chromeos-releases-data/data.json"
    local mercury_url=$(curl -ks "$mercury_data_url" | jq -r --arg board "$board" --arg version "$recoveryver" '
      .[$board].images
      | map(select(
          .channel == "stable-channel" and
          (.chrome_version | type) == "string" and
          (.chrome_version | startswith($version + "."))
        ))
      | sort_by(.platform_version)
      | .[0].url
    ')

    if [ -n "$mercury_url" ] && [ "$mercury_url" != "null" ]; then
        echo "Found a match!"
        FINAL_URL="$mercury_url"
        MATCH_FOUND=1
        echo "$mercury_url"
   else
		recoveryver=126
		findimage
    fi 
}
check_deps() {
	for dep in "$@"; do
		command -v "$dep" &>/dev/null || echo "$dep"
	done
}
missing_deps=$(check_deps partx sgdisk mkfs.ext4 cryptsetup lvm numfmt tar jq curl wget) # more are needed for br0ker
[ "$missing_deps" ] && fail "The following required commands weren't found in PATH:\n${missing_deps}"

findimage

echo "Downloading $recoveryver recovery image"

wget "$FINAL_URL" -O recovery.zip >/dev/null 2>&1 || fail "Failed to download recovery image"

echo "Extracting $recoveryver recovery image"
unzip recovery.zip || fail "Failed to unzip recovery image"

echo "Deleting $recoveryver recovery image zip (unneeded now)"
rm recovery.zip || fail "Failed to delete zipped recovery image"

#more murkmod code
FILENAME=$(find . -maxdepth 2 -name "chromeos_*.bin") # 2 incase the zip format changes
mv $FILENAME badsh1mmer-large-$board.bin
FILENAME=$(find . -maxdepth 2 -name "badsh1mmer-large-*.bin")
echo "Found recovery image from archive at $FILENAME"

# echo "running update_downloader.sh"
# bash update_downloader.sh "$board" || fail "update_downloader.sh exited with an error"

echo "running build_badrecovery.sh (requires root)"
sudo bash ./build_badrecovery.sh -i "$FILENAME" -t unverified || fail "build_badrecovery.sh exited with an error"

echo "removing unallocated space from $FILENAME"
SMALLFILE=$(echo "$FILENAME" | sed "s/-large//")
sudo bash ./shrink_image.sh $FILENAME $SMALLFILE || fail "shrink_image.sh exited with an error"
echo "cleaning up directory"
rm $FILENAME
# rm badsh1mmer/scripts/root.gz
# rm badsh1mmer/scripts/kern.gz
echo "File saved to $SMALLFILE"
