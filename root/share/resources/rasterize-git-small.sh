#!/bin/sh

if [ "$1" = "sdk" ]; then
    option="-negate"
    suffix="-sdk"
fi

convert -colorspace sRGB -density 256x256 Git-Icon-1788C.eps $option \
    -resize 55x55 -gravity center -extent 55x58 -alpha off -colors 256 \
    git-small$suffix.bmp
