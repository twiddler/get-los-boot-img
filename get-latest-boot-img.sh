#!/bin/bash

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

# Install payload dumper
cd "$WORK_DIR"
git clone https://github.com/vm03/payload_dumper.git --depth 1
cd payload_dumper
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt

# Download image
cd "$WORK_DIR"
buildhtml=$(wget -O - https://download.lineageos.org/alioth)
latestbuildwithhref=$(echo $buildhtml | xmllint --html --xpath "/html/body/main/div/div/div/div/div/table/tbody/tr[1]/td[3]/a/@href" - 2>/dev/null | xargs)
latestbuild=${latestbuildwithhref#href=}
latestbuildsha="${latestbuild}?sha256"
latestbuildname="${latestbuild##*/}"
wget -O "$latestbuildname" "$latestbuild"
wget -O "${latestbuildname}.zip.sha256" "$latestbuildsha"
sha256sum -c *.sha256

# Get boot.img
unzip "$latestbuildname" -d unzipped
python3 payload_dumper/payload_dumper.py unzipped/payload.bin --out out --images boot

# Copy to Downloads
mkdir -p ~/Downloads
cp out/boot.img ~/Downloads/${latestbuildname}.boot.img
