#!/bin/sh

# Limit the number of RSS feed entries.
limit=200

# Get the download link to the most recent version of mingw-get.
link=$(curl -s http://sourceforge.net/api/file/index/project-id/2435/mtime/desc/limit/$limit/rss |
     sed -nr "s/<link>(.+(mingw-get-[0-9]+\.[0-9]+-mingw32-.+-bin\.tar\.xz).+)<\/link>/\2\t\1/p" |
     head -1)

file=$(echo "$link" | cut -f 1)
url=$(echo "$link" | cut -f 2)

# Trim whitespaces.
file=$(echo $file)
url=$(echo $url)

mkdir -p root/mingw && cd root/mingw && (
    if [ -n "$url" ]; then
        echo "Downloading $file ..."
        curl -# -L $url | tar -xJ
    else
        echo "Warning: Invalid URL, skipping download of mingw-get."
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
        echo "Warning: mingw-get not found, skipping download of catalogues."
    fi
)
