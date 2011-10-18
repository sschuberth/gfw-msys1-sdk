#!/bin/sh

# Limit the number of RSS feed entries.
limit=500

# Get the download link to the most recent version of mingw-get.
if [ -f "$(which xz)" ]; then
    ext="\.tar\.xz"
    unpack="tar -xf"
elif [ -f "$(which unzip)" ]; then
    ext="\.zip"
    unpack="unzip -u"
else
    echo "ERROR: No suitable unpacking tool found."
    exit 1
fi

link=$(curl -s http://sourceforge.net/api/file/index/project-id/2435/mtime/desc/limit/$limit/rss |
     sed -nr "s/<link>(.+(mingw-get-[0-9]+\.[0-9]+-mingw32-.+-bin$ext).+)<\/link>/\2\t\1/p" |
     head -1)

file=$(echo "$link" | cut -f 1)
url=$(echo "$link" | cut -f 2)

# Trim whitespaces.
file=$(echo $file)
url=$(echo $url)

mkdir -p root/mingw && cd root/mingw && (
    if [ -n "$url" ]; then
        echo "Downloading $file ..."
        curl -# -L $url -o $file
        $unpack $file
        rm $file
    else
        echo "WARNING: Invalid URL, skipping download of mingw-get."
    fi

    if [ -f bin/mingw-get ]; then
        version=$(bin/mingw-get --version | head -1)
        echo "Using $version."

        # Install mingw in a directory below the msys root.
        cat > var/lib/mingw-get/data/profile.xml << EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<profile project="MinGW" application="mingw-get">
    <repository uri="http://prdownloads.sourceforge.net/mingw/%F.xml.lzma?download">
    </repository>
    <repository uri="https://github.com/downloads/sschuberth/mingwGitDevEnv/%F.xml.lzma">
      <package-list catalogue="mingwgitdevenv-package-list" />
    </repository>
    <system-map id="default">
      <sysroot subsystem="mingw32" path="%R" />
      <sysroot subsystem="msys" path="%R/../" />
    </system-map>
</profile>
EOF

        # Get the list of available packages.
        echo "Downloading catalogues ..."
        bin/mingw-get update
    else
        echo "WARNING: mingw-get not found, skipping download of catalogues."
    fi
)
