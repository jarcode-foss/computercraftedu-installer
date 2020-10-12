#!/bin/bash
set -e
rm -rf pkg_out
mkdir pkg_out

./package_arch.sh
target=`cat build/arch_targetfile`
cp build/$target pkg_out

./package_debian.sh
target=`cat build/deb_targetfile`
cp build/$target pkg_out

./package_osx.sh
target=`cat build/osx_targetfile`
cp build/$target pkg_out

rm -rf build
meson build --buildtype=release --cross-file win64_host.ini
ninja -C build
target=`cat build/msi_targetfile`
cp build/$target pkg_out

rm -rf build
meson build --buildtype=release --cross-file win32_host.ini
ninja -C build
target=`cat build/msi_targetfile`
cp build/$target pkg_out

rm -rf build
