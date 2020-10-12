#!/bin/bash
# Prototype script that once processed, generates an OSX package.
#
# IMPORTANT: this is not meant for package maintainers.
#
# (build_dir, ...)
sed \
    -e "s/\${NAME}/${2}/g" \
    -e "s/\${VERSION}/${3}/g" \
    -e "s/\${DESC}/${4}/g" \
    -e "s/\${AUTHOR}/${5}/g" \
    -e "s/\${EMAIL}/${6}/g" \
    -e "s/\${YEAR}/${7}/g" \
    -e "s/\${MANUFACTURER}/${8}/g" \
    -e "s/\${FMT_NAME}/${9}/g" \
    generate_pkg.sh | tail -n +`grep -n "^exit 0" generate_pkg.sh | cut -f1 -d:` | tail -n +2 > "${1}/osxbuild.sh"
chmod a+x "${1}/osxbuild.sh"
exit 0
#!/bin/bash
set -e
mkdir osx_pkg
cd osx_pkg
mkdir -p "root/Applications/${NAME}.app" flat/base.pkg flat/Resources/en.lproj
pkgdir=`readlink -f root/Applications/${NAME}.app`
DESTDIR="${pkgdir}" LD_LIBRARY_PATH=/opt/osxcross/lib ninja -C .. install
mv "root/Applications/${NAME}.app/content/icon.png" "root/Applications/${NAME}.app/"
rm "root/Applications/${NAME}.app/content/icon.ico"
touch "root/Applications/${NAME}.app/Info.plist"
echo -e '<?xml version="1.0" encoding="UTF-8"?>\n'\
       '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'\
       '<plist version="1.0">\n'\
       '  <dict>\n'\
       '    <key>CFBundleInfoDictionaryVersion</key>\n'\
       '    <value>6.0</value>\n'\
       '    <key>CFBundlePackageType</key>\n'\
       '    <string>APPL</string>\n'\
       '    <key>CFBundleDevelopmentRegion</key>\n'\
       '    <string>en-US</string>\n'\
       '    <key>CFBundleExecutable</key>\n'\
       '    <string>${NAME}</string>\n'\
       '    <key>CFBundleDisplayName</key>\n'\
       '    <string>${FMT_NAME}</string>\n'\
       '    <key>CFBundleName</key>\n'\
       '    <string>${FMT_NAME}</string>\n'\
       '    <key>CFBundleIdentifier</key>\n'\
       '    <string>${MANUFACTURER}.${NAME}</string>\n'\
       '    <key>CFBundleVersion</key>\n'\
       '    <string>${VERSION}</string>\n'\
       '    <key>CFBundleIconFile</key>\n'\
       '    <string>icon.png</string>\n'\
       '    <key>LSRequiresNativeExecution</key>\n'\
       '    <boolean>true</boolean>\n'\
       '    <key>LSMultipleInstancesProhibited</key>\n'\
       '    <boolean>true</boolean>\n'\
       '    <key>LSArchitecturePriority</key>\n'\
       '    <array><string>x86_64</string></array>\n'\
       '    <key>LSMinimumSystemVersion</key>\n'\
       '    <string>10.7.0</string>\n'\
       '    <key>UIRequiredDeviceCapabilities</key>\n'\
       '    <array></array>\n'\
       '  </dict>\n'\
       '</plist>\n' > "root/Applications/${NAME}.app/Info.plist"
(cd root && find . | cpio -o --format odc --owner 0:80 | gzip -c) > flat/base.pkg/Payload
NUM_FIILES=`find root | wc -l`
TOTAL_SZ=`du -b -s root | awk '{ print $1 }'`
TOTAL_SZ=$(((TOTAL_SZ + 1023) / 1024))
touch flat/base.pkg/PackageInfo
echo -e '<pkg-info format-version="2" identifier="${MANUFACTURER}.${NAME}.base.pkg" version="${VERSION}" install-location="/" auth="root">\n'\
       '  <payload installKBytes="${TOTAL_SZ}" numberOfFiles="${NUM_FILES}"/>\n'\
       '  <scripts>\n'\
       '    <postinstall file="./postinstall"/>\n'\
       '  </scripts>\n'\
       '  <bundle-version>\n'\
       '    <bundle id="${MANUFACTURER}.${NAME}" CFBundleIdentifier="${MANUFACTURER}.${NAME}" path="./Applications/${NAME}.app" CFBundleVersion="${VERSION}"/>\n'\
       '  </bundle-version>\n'\
       '</pkg-info>\n' > flat/base.pkg/PackageInfo
mkdir scripts
touch scripts/postinstall
chmod a+x scripts/postinstall
echo -e "#!/bin/bash\n"\
       "osascript -e 'tell app \"Finder\" to display dialog \"${NAME} installed!\"'\n"\
       > scripts/postinstall
(cd scripts && find . | cpio -o --format odc --owner 0:80 | gzip -c) > flat/base.pkg/Scripts
mkbom -u 0 -g 80 root flat/base.pkg/Bom
touch flat/Distribution
echo -e '<?xml version="1.0" encoding="utf-8"?>\n'\
       '<installer-script minSpecVersion="1.000000" authoringTool="com.apple.PackageMaker" authoringToolVersion="3.0.3" authoringToolBuild="174">\n'\
       '  <title>${FMT_NAME} ${VERSION}</title>\n'\
       '  <options customize="never" allow-external-scripts="no"/>\n'\
       '  <domains enable_anywhere="true"/>\n'\
       '  <installation-check script="pm_install_check();"/>\n'\
       '  <script>\n'\
       '    function pm_install_check() {\n'\
       "      if(!(system.compareVersions(system.version.ProductVersion,'10.7') >= 0)) {\n"\
       "        my.result.title = 'Failure';\n"\
       "        my.result.message = 'You need at least Mac OS X 10.7 to install ${FMT_NAME}.';\n"\
       "        my.result.type = 'Fatal';\n"\
       '        return false;\n'\
       '      }\n'\
       '      return true;\n'\
       '    }\n'\
       '  </script>\n'\
       '  <choices-outline>\n'\
       '    <line choice="choice1"/>\n'\
       '  </choices-outline>\n'\
       '  <choice id="choice1" title="base">\n'\
       '    <pkg-ref id="${MANUFACTURER}.${NAME}.base.pkg"/>\n'\
       '  </choice>\n'\
       '  <pkg-ref id="${MANUFACTURER}.${NAME}.base.pkg" installKBytes="${TOTAL_SZ}" version="${VERSION}" auth="Root">#base.pkg</pkg-ref>\n'\
       '</installer-script>\n' > flat/Distribution
(cd flat && xar --compression none -cf "../../${NAME}-${VERSION}-installer.pkg" *)
cd ..
echo -n "${NAME}-${VERSION}-installer.pkg" > osx_targetfile
