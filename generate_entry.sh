#!/bin/bash
# Script for generating freedesktop `.desktop` entries
# (input, build_dir, name, ...)
sed \
    -e "s:\${APP}:${4}:" \
    -e "s:\${DESC}:${5}:" \
    -e "s:\${EXEC}:${6}:" \
    -e "s:\${ICON}:${7}:" \
    ${1} > "${2}/${3}.desktop"
