#!/bin/bash
# Script for generating .wxs fragments for building windows MSI
# (working_dir, build_dir, lua_dir, output, ..., arch)
cd "${1}"
sed \
    -e "s/\${APP}/${5}/" \
    -e "s/\${VERSION}/${6}/" \
    -e "s/\${MANUFACTURER}/${7}/" \
    -e "s/\${AUTHOR}/${8}/" \
    -e "s/\${APP_EXEC}/${9}/" \
    -e "s/\${YEAR}/${10}/" \
    -e "s/\${T}/`date +%s`/" \
    package.wxs > "${2}/p_out.wxs"
cwd=$(pwd)
sed '/__SPLIT__/q' "${2}/p_out.wxs" | head -n -1 >| "${2}/p_post.wxs"
cd "${2}"
# shitfuckery to deal with the expected symlink
T=`find $3 -type l -print`
find `echo $T | xargs realpath` -name *.lua | xargs -L1 basename | awk -v t="$T" '{print t "/" $0}' | awk '{print "./" $0}' | wixl-heat --directory-ref INSTALLDIR --component-group BaseLua -p ./ --var V | sed -e "s/\$(V)/${2//\//\\/}/" | sed -e '1,2d' | head -n -3 >> p_post.wxs
cd $cwd
find resources -type f -print | awk '{print "./" $0}' | wixl-heat --directory-ref INSTALLDIR --component-group BaseResources -p ./ --var sys.CURRENTDIR | sed -e '1,2d' | head -n -3 >> "${2}/p_post.wxs"

find config -type f -print | wixl-heat --directory-ref INSTALLDIR --component-group BaseConfig -p config/ --var V | sed -e "s/\$(V)/config/" | sed -e '1,2d' | head -n -3 >> "${2}/p_post.wxs"
sed -n -e '/__SPLIT__/,$p' "${2}/p_out.wxs" | sed -e '1,1d' >> "${2}/p_post.wxs"
wixl -D "BuildArch=${11}" -a ${11} -I "${2}" -o "${2}/${4}.msi" "${2}/p_post.wxs"
cd "${2}"
echo "${4}.msi" > msi_targetfile
