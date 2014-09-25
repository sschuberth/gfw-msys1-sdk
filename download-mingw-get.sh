#!/bin/sh

. download-tool-lib.sh

# Limit the number of RSS feed entries.
url=http://sourceforge.net/projects/mingw/rss?limit=500

# Parse the RSS feed for the most recent download link and construct a line with the file name and URL separated by a
# tab character so we can easily separate it via "cut" later.
link=$($download $download_args_rss $url |
     sed $sed_args "s/<link>(.+(mingw-get-[0-9]+(\.[0-9]+){1,}-mingw32-.+-bin$ext).+)<\/link>/\2	\1/p" |
     head -1)

file=$(echo "$link" | cut -f 1)
url=$(echo "$link" | cut -f 2)

# Trim whitespaces.
file=$(echo $file)
url=$(echo $url)

mkdir -p root/mingw && cd root/mingw && (
    if [ -n "$url" ]; then
        echo "Downloading $file ..."
        file="../../$file"
        if [ "$download" == "curl" ]; then
            download_args="$download_args $file -R -z"
        fi
        $download $download_args $file $url
        $unpack $file
    else
        echo "WARNING: Invalid URL, skipping download of mingw-get."
    fi

    if [ -f bin/mingw-get.exe ]; then
        wine=$(type -p wine)
        if [ $? -eq 0 ]; then
            version=$($wine bin/mingw-get.exe --version 2> /dev/null | grep -m 1 -o -P ".*version.*[^\s]")
        else
            version=$(bin/mingw-get.exe --version | head -1)
        fi
        if [ -z "$version" ]; then
            echo "ERROR: Unable to execute mingw-get."
            exit 2
        fi
        echo "Using $version."

        # Install mingw in a directory below the msys root.
        cat > var/lib/mingw-get/data/profile.xml << EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<profile project="MinGW" application="mingw-get">
    <repository uri="http://prdownloads.sourceforge.net/mingw/%F.xml.lzma?download">
    </repository>
    <repository uri="https://github.com/git-for-windows/sdk-packages/blob/master/%F.xml.lzma?raw=true">
      <package-list catalogue="git-win-sdk-package-list" />
    </repository>
    <system-map id="default">
      <sysroot subsystem="mingw32" path="%R" />
      <sysroot subsystem="msys" path="%R/../" />
    </system-map>
</profile>
EOF

        # Remove all packages first as updating does not seem to always overwrite old files reliably.
        rm -f var/lib/mingw-get/data/mingw*.xml var/lib/mingw-get/data/msys*.xml

        # Get the list of available packages.
        echo "Downloading catalogues ..."
        $wine bin/mingw-get.exe update
    else
        echo "WARNING: mingw-get not found, skipping download of catalogues."
    fi
)
