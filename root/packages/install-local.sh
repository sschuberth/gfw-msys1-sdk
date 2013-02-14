#!/bin/sh

for path in $(find . -name "*.tar.lzma" -not -name "*-src.*"); do
    case $(basename $path) in
    *mingw32*)
        tar vxf $path -C /mingw/
        ;;
    *msys*)
        tar vxf $path -C /
        ;;
    esac
done
