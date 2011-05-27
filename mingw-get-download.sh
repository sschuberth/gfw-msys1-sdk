#!/bin/sh

# Limit the number of RSS feed entries.
limit=100

# Get the download link to the most recent version of mingw-get.
link=$(curl -s http://sourceforge.net/api/file/index/project-id/2435/mtime/desc/limit/$limit/rss |
     sed -nr "s/<link>(.+mingw-get-[0-9]+\.[0-9]+-mingw32-.+-bin\.tar.+)<\/link>/\1/p" |
     head -1)

mkdir -p mingw-get && curl -L $link | tar -xzC mingw-get
