#!/bin/bash
# simple passthrough script + downloading a 129 image
echo "welcome to the full BadSH1mmer Builder!"

board=$1
fail() {
    printf "%b\n" "$1" >&2
    printf "error occurred\n" >&2
    exit 1
}
findimage(){ # Taken from murkmod
    echo "Attempting to find recovery image from https://github.com/MercuryWorkshop/chromeos-releases-data data..."
    local mercury_data_url="https://raw.githubusercontent.com/MercuryWorkshop/chromeos-releases-data/refs/heads/main/data.json"
    local mercury_url=$(curl -ks "$mercury_data_url" | jq -r --arg board "$board" --arg version 129 '
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
    fi
}
check_deps() {
	for dep in "$@"; do
		command -v "$dep" &>/dev/null || echo "$dep"
	done
}
missing_deps=$(check_deps partx sgdisk mkfs.ext4 cryptsetup lvm numfmt tar curl git python3 protoc gzip jq)
[ "$missing_deps" ] && fail "The following required commands weren't found in PATH:\n${missing_deps}"

findimage

echo "Downloading 129 recovery image"
curl --progress-bar -k "$FINAL_URL" -o recovery.zip || fail "Failed to download recovery image"

echo "Extracting 129 recovery image"
unzip recovery.zip || fail "Failed to unzip recovery image"

echo "Deleting 129 recovery image zip (unneeded now)"
rm recovery.zip || fail "Failed to delete zipped recovery image"

#more murkmod code
FILENAME=$(find . -maxdepth 2 -name "chromeos_*.bin") # 2 incase the zip format changes
echo "Found recovery image from archive at $FILENAME"

echo "running update_downloader.sh"
bash update_downloader.sh "$board" || fail "update_downloader.sh exited with an error"

echo "running build_badrecovery.sh"
sudo ./build_badrecovery.sh -i "$FILENAME" -t unverified || fail "build_badrecovery.sh exited with an error"
echo "Cleaning up directory"
rm badsh1mmer/scripts/root.gz
rm badsh1mmer/scripts/kern.gz
echo "No errors detected while buildng the badsh1mmer image"
echo "File saved to $FILENAME"
