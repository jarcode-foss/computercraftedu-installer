#!/bin/bash
rm -rf pkg_out
mkdir pkg_out

./package_arch
target=`cat build/arch_targetfile`
cp $target pkg_out/

./package_debian
target=`cat build/deb_targetfile`
cp $target pkg_out/

rm -rf build
meson build --buildtype=release --cross-file win64_host.ini
target=`cat build/deb_targetfile`
cp $target pkg_out/
