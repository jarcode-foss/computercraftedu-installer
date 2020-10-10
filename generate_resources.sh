#!/bin/bash
# Script for preprocessing windows resource file
# (exec, input, include_dir, build_dir, ...)
sed \
    -e "s/\${APP}/${5}/" \
    -e "s/\${VERSION}/${6}/" \
    -e "s/\${MANUFACTURER}/${7}/" \
    -e "s/\${AUTHOR}/${8}/" \
    -e "s/\${NAME}/${9}/" \
    -e "s/\${DESC}/${10}/" \
    ${2} > "${4}/r_post.rc"
${1} -I"${3}" "${4}/r_post.rc" "${4}/resources.o"
