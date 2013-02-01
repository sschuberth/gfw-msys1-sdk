#!/bin/sh

for xml in *.xml; do
    lzma -f -k $xml
done
