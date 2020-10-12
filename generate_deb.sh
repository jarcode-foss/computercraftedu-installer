#!/bin/bash
# Prototype script that once processed, generates a debian package tree that
# can be packaged directly in the build directory, under `pkg`.
#
# IMPORTANT: this is not meant for package maintainers.
#
# (build_dir, ...)
sed \
    -e "s/\${NAME}/${2}/" \
    -e "s/\${VERSION}/${3}/" \
    -e "s/\${DESC}/${4}/" \
    -e "s/\${AUTHOR}/${5}/" \
    -e "s/\${EMAIL}/${6}/" \
    -e "s/\${YEAR}/${7}/" \
    -e "s/\${ARCH}/${8}/" \
    generate_deb.sh | tail -n +`grep -n "^exit 0" generate_deb.sh | cut -f1 -d:` | tail -n +2 > "${1}/debbuild.sh"
chmod a+x "${1}/debbuild.sh"
exit 0

rm -rf pkg
mkdir pkg
mkdir pkg/debian
mkdir pkg/debian/source

DEBEMAIL='${EMAIL}'
DEBFULLNAME='${NAME}'
DISTRIB_ID=`cat /etc/*{release,version} 2>/dev/null | grep DISTRIB_ID | cut -d "=" -f2`
pkgver=`echo '${VERSION}' | sed "s/-/+/g"`
pkgdate=`date +"%a, %d %b %Y %R:%S %z"`
pkgdir=`readlink -f pkg/debian/${NAME}`
cd pkg/debian
echo "Source: ${NAME}"                   >> control
echo "Section: games"                    >> control
echo "Priority: optional"                >> control
echo "Maintainer: ${AUTHOR} <${EMAIL}>"  >> control
echo "Build-Depends: "                   >> control
echo "Standards-Version: 4.0.0"          >> control
echo "Homepage:"                         >> control
echo ""                                  >> control
echo "Package: ${NAME}"                  >> control
echo "Architecture: ${ARCH}"             >> control
echo "Depends: \${misc:Depends}, liblua5.1, curl" >> control
echo "Description: ${DESC}"              >> control

echo "Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/" >> copyright
echo "Upstream-Name: ${NAME}"                  >> copyright
echo "Upstream-Contact: ${AUTHOR} <${EMAIL}>"  >> copyright
echo ""                                        >> copyright
echo "Files: *"                                >> copyright
echo "Copyright: ${YEAR} ${AUTHOR} <${EMAIL}>" >> copyright
echo "License: GPL-3"                          >> copyright

echo "${NAME} (${pkgver}) UNRELEASED; urgency=medium"    >> changelog
echo ""                                                  >> changelog
echo "  * Generated debian package from project source." >> changelog
echo ""                                                  >> changelog
echo " -- ${AUTHOR} <${EMAIL}>  ${pkgdate}"              >> changelog

echo "#!/usr/bin/make -f" >> rules
echo "package = ${NAME}"  >> rules
echo -e "%:\n\tdh \$@ --without autoreconf"       >> rules
echo -e "\noverride_dh_auto_clean: ;"             >> rules
echo -e "\noverride_dh_auto_configure: ;"         >> rules
echo -e "\noverride_dh_auto_build:\n\tninja -C .." >> rules
echo -e "\noverride_dh_auto_test: ;"              >> rules
echo -e "\noverride_dh_auto_install:\n\tDESTDIR=\"${pkgdir}\" ninja -C .. install" >> rules
if [[ $DISTRIB_ID == Arch ]]
then
    echo -e "\noverride_dh_shlibdeps:\n\tdh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info" >> rules
fi

echo 10 > compat
echo "3.0 (quilt)" > source/format

chmod a+x rules

cd ../..

echo -n "${NAME}_${VERSION}_${ARCH}.deb" > deb_targetfile
