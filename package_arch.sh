#!/bin/bash
# Perform a clean release build, build an Arch Linux package, and then install it.
#
# IMPORTANT: this is not meant for package maintainers.
#
rm -rf build
meson build --prefix=/usr --buildtype=release
cd build
# `makepkg -srif` to include automatic installation
makepkg -srf
target=`cat arch_targetfile`
echo "Package Built: '${target}'"
if [[ $1 == install ]]
then
    sudo pacman -U $target
fi
