#!/bin/sh

# See
#     http://www.imagemagick.org/Usage/thumbnails/#favicon
# and
#     http://msdn.microsoft.com/en-us/library/windows/desktop/aa511280.aspx#size
# for details.
convert -colorspace sRGB -density 256x256 Git-Icon-1788C.eps \
    \( -clone 0 -resize 16x16 \) \
    \( -clone 0 -resize 24x24 \) \
    \( -clone 0 -resize 32x32 \) \
    \( -clone 0 -resize 48x48 \) \
    \( -clone 0 -resize 64x64 \) \
    \( -clone 0 -resize 256x256 \) \
    \( -clone 0 -resize 16x16 -bordercolor white -border 0 -alpha off -colors 256 \) \
    \( -clone 0 -resize 24x24 -bordercolor white -border 0 -alpha off -colors 256 \) \
    \( -clone 0 -resize 32x32 -bordercolor white -border 0 -alpha off -colors 256 \) \
    \( -clone 0 -resize 48x48 -bordercolor white -border 0 -alpha off -colors 256 \) \
    \( -clone 0 -resize 64x64 -bordercolor white -border 0 -alpha off -colors 256 \) \
    -delete 0 git.ico
