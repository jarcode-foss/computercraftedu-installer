#!/bin/bash
# PKGBUILD prototype script for quickly building archlinux packages.
#
# IMPORTANT: this is not meant for package maintainers.
#
# (build_dir, ...)
sed \
    -e "s/\${NAME}/${2}/" \
    -e "s/\${VERSION}/${3}/" \
    -e "s/\${DESC}/${4}/" \
    generate_pkgbuild.sh | tail -n +`grep -n "^exit 0" generate_pkgbuild.sh | cut -f1 -d:` | tail -n +2 > "${1}/PKGBUILD"

exit 0

pkgname=${NAME}
pkgver=`echo '${VERSION}' | sed "s/-/+/g"`
pkgrel=1
pkgdesc='${DESC}'
arch=('x86_64')
license=('GPL3')
depends=('glfw' 'freetype2' 'libuv' 'luajit')
makedepends=('git')

build() {
    cd ..
    ninja -C .
}

package() {
    cd ..
    DESTDIR="${pkgdir}" ninja -C . install
    echo "${pkgname}-${pkgver}-${pkgrel}-${arch}.pkg.tar.zst" > arch_targetfile
}
