#!/bin/bash
# simple passthrough script + downloading a 129 image

board=$1
fail() {
    printf "%s\n" "$1"
    printf "error occurred\n"
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
wget "$mercury_url" || fail "Failed to download recovery image"

echo "Extracting 129 recovery image"
unzip "$recozippedpath" || fail "Failed to unzip recovery image"

echo "Deleting 129 recovery image zip (unneeded now)"
rm "$recozippedpath" || fail "Failed to delete zipped recovery image"

echo "running update_downloader.sh"
bash update_downloader.sh "$board" || fail "update_downloader.sh exited with an error"

echo "running build_badrecovery.sh"
sudo ./build_badrecovery.sh -i "$recopath" -t unverified || fail "build_badrecovery.sh exited with an error"
echo "Cleaning up directory"
rm -rf unverified/16093
echo "No errors detected while buildng the badbr0ker image"
echo "File saved to $recopath"
