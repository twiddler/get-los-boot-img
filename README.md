# What is this?

This script downloads the `boot.img` of the latest LineageOS update for your device. This is useful if you want to patch the `boot.img` with [Magisk](https://github.com/topjohnwu/Magisk) to root your device.

# How to use

Run `./get-latest-boot-img.sh [name of your device]` to download the `boot.img` for your device. If you do not provide a name, it defaults to `alioth`.

# Supported devices

I only tested this script with `alioth`, so this might not work for your device. If it doesn't, feel free to open a pull request to fix that.

# Supported distributions

I only tested this script on Fedora 37. If it does not run on your distribution of choice, feel free to open a pull request to fix that.
