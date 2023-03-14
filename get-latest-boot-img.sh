#!/bin/bash

# Get device from argument, or default to `alioth` if none given
if [ $# -eq 0 ]; then
    device=alioth
else
    device=$1
fi
echo "Getting latest boot.img for device $device"

# Create temporary directory and automatically remove it when we are done. Credits to Ortwin Angermeier, https://stackoverflow.com/a/34676160
WORK_DIR=$(mktemp -d)
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    echo "Could not create temp dir. Exiting."
    exit 1
fi
function cleanup {
    rm -rf "$WORK_DIR"
    echo "Deleted temp working directory $WORK_DIR."
}
trap cleanup EXIT

# set the base download URL
url_base="https://mirrorbits.lineageos.org/full/${device}"

# initialize the build number to today's date
build_num=$(date +%Y%m%d)

# loop through the last two weeks until a valid build is found
for i in {0..13}; do
    # construct the URL for the latest build of the given date
    url="${url_base}/${build_num}/boot.img"

    # check if the file exists
    echo -n "Checking if ${url} exists ... "
    if wget --spider $url 2>/dev/null; then
        # if the file exists, break out of the loop
        echo "found!"
        break
    else
        # if it doesn't exist, try one day earlier
        echo "nothing here."
        build_num=$(date -d "$build_num - 1 day" +%Y%m%d)
    fi
done

# check if a valid build was found
if [ "$i" -eq 14 ]; then
    echo "Could not find a valid build to download. You might want to check the downloads page yourself: https://download.lineageos.org/devices/alioth/builds"
    exit 1
fi

# download and verify boot.img
cd "$WORK_DIR"
echo ""
echo "Downloading ${url} ..."
curl -Lo "boot.img" "${url}"

echo ""
echo "Downloading checksum ..."
curl -Lo "boot.img.sha256" "${url}?sha256"

echo ""
echo "Verifying download ..."
sha256sum -c "boot.img.sha256"

# copy to downloads
mkdir -p "$HOME/Downloads"
cp boot.img "$HOME/Downloads/${device}-${build_num}.boot.img"
echo ""
echo "boot.img downloaded and saved to $HOME/Downloads/${device}-${build_num}.boot.img! 🥳"
