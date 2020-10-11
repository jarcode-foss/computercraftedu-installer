#!/bin/bash
# Perform a clean release build, build a Debian package, and then install it.
#
# IMPORTANT: this is not meant for package maintainers
#
rm -rf build
meson build --prefix=/usr --buildtype=release
cd build
./debbuild.sh
cd pkg
dpkg-buildpackage -b -us -uc
cd ..
target=`cat deb_targetfile`
echo "Package Built: '${target}'"
# sudo dpkg -i $target
# sudo apt-get install -f
