#!/bin/bash

# Get device from argument, or default to `alioth` if none given
if [ $# -eq 0 ]; then
    device=alioth
else
    device=$1
fi
echo "We will try to download the latest boot.img for device ${device}. If you want to download the boot.img for a different device, you can pass it as an argument to this script: ./get-latest-boot-img.sh <device>"

# Create and switch to a new temporary directory. Remove it when we are done. Credits to Ortwin Angermeier, https://stackoverflow.com/a/34676160
WORK_DIR=$(mktemp -d)
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    echo ""
    echo "Could not create temp dir. Exiting."
    exit 1
fi
function cleanup {
    rm -rf "$WORK_DIR"
    echo ""
    echo "Deleted temp working directory $WORK_DIR."
}
trap cleanup EXIT
cd "$WORK_DIR"

# Get information about the latest build.
echo ""
echo "Downloading info about latest build …"
latestBuild=$(curl -sL https://download.lineageos.org/api/v2/devices/${device}/builds | jq -r '.[0]')

# Download and verify boot.img.
latestBootImg=$(echo ${latestBuild} | jq -r '.files[] | select(.filename == "boot.img")')

echo ""
url=$(echo ${latestBootImg} | jq -r '.url')
echo "Downloading ${url} …"
curl -Lo "boot.img" "${url}"

echo ""
echo "Downloading checksum …"
checksum=$(echo ${latestBootImg} | jq -r '.sha256')

echo ""
echo "Verifying download …"
sha256sum -c <<<"${checksum} boot.img"

# copy to downloads
mkdir -p "$HOME/Downloads"
latestBuildDate=$(echo ${latestBuild} | jq -r '.date')
saveAs="${HOME}/Downloads/${device}.${latestBuildDate}.boot.img"
cp boot.img "${saveAs}"
echo ""
echo "boot.img downloaded and saved to ${saveAs}! 🥳"
