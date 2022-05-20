#!/bin/bash

# Collect home directories
unset options i
while IFS= read -r -d $'\0' f; do
    options[i++]="$f/Downloads"
done < <(find "/home" -maxdepth 1 -mindepth 1 -type d -print0)
options[i++]="/root/Downloads"

# Let user select home directory
echo "Select a home directory to store the boot.img."
select opt in "${options[@]}" "Abort"; do
    case $opt in
    *Downloads) break ;;
    "Abort") exit ;;
    esac
done

# Get device from argument, or default to `alioth` if none given
if [ $# -eq 0 ]; then
    DEVICE=alioth
else
    DEVICE=$1
fi
echo "Getting latest boot.img of device $DEVICE"

# Create temporary directory and automatically remove it when we are done.
# Credits to Ortwin Angermeier, https://stackoverflow.com/a/34676160
WORK_DIR=$(mktemp -d)
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    echo "Could not create temp dir"
    exit 1
fi
function cleanup {
    rm -rf "$WORK_DIR"
    echo "Deleted temp working directory $WORK_DIR"
}
trap cleanup EXIT

# Download image
cd "$WORK_DIR"
buildhtml=$(curl "https://download.lineageos.org/$DEVICE")
latestbuildwithhref=$(echo $buildhtml | xmllint --html --xpath "/html/body/main/div/div/div/div/div/table/tbody/tr[1]/td[3]/a/@href" - 2>/dev/null | xargs)
latestbuild=${latestbuildwithhref#href=}
latestbootimg="$(dirname $latestbuild)/boot.img"
latestbuildname="${latestbuild##*/}"
curl -Lo "boot.img" "$latestbootimg"
curl -Lo "boot.img.sha256" "${latestbootimg}?sha256"
sha256sum -c "boot.img.sha256"

# Copy to Downloads
mkdir -p "${opt}"
cp boot.img "${opt}/${latestbuildname}.boot.img"
