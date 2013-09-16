#!/bin/sh

convert -colorspace sRGB -density 256x256 Git-Icon-1788C.eps -negate \
    -resize 55x55 -gravity center -extent 55x58 -alpha off -colors 256 \
    git-small.bmp
