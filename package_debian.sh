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
# The debian build process wants a particular host machine string, which has a mismatch on Arch
# If this is an issue, we spit out a wrapper script that corrects this
CC_USE=${CC:-cc}
CC_MACHINE=`cc -dumpmachine`
if [[ $CC_MACHINE != x86_64-linux-gnu ]]
then
    touch cc-wrapper
    chmod a+x cc-wrapper
    echo -e "#\!/bin/bash\nif [[ \$1 == -dumpmachine* ]]\nthen\necho \"x86_64-linux-gnu\"\nelse\nexec cc \"\$@\"\nfi\n" > cc-wrapper
    CC_USE=cc-wrapper  
fi
CC=$CC_USE dpkg-buildpackage -B -d -us -uc -a amd64
cd ..
target=`cat deb_targetfile`
echo "Package Built: '${target}'"
if [[ $1 == install ]]
then
    sudo dpkg -i $target
    sudo apt-get install -f
fi
