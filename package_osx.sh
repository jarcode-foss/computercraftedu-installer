#!/bin/bash
# Perform a clean release build, build an Arch Linux package, and then install it.
#
# IMPORTANT: this is not meant for package maintainers.
#
rm -rf build
LD_LIBRARY_PATH=/opt/osxcross/lib meson build --prefix=/ --buildtype=release --cross-file osx_host.ini
cd build
./osxbuild.sh
target=`cat osx_targetfile`
echo "Package Built: '${target}'"
