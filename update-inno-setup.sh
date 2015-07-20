#!/bin/sh

. ./download-tool-lib.sh

# Download the most recent Inno Setup version.
file="is-unicode.exe"
url="http://www.jrsoftware.org/download.php/$file"

if [ "$download" == "curl" ]; then
    download_args="$download_args $file -R -z"
fi
$download $download_args $file $url

if [ -f $file ]; then
    # Remove any previous installation.
    rm -fr root/share/InnoSetup/

    # Silently install Inno Setup below the mingw root.
    wine=$(type -p wine)
    if [ $? -eq 0 ]; then
        $wine $file /verysilent /dir="root\share\InnoSetup" /noicons /tasks="" /portable=1
    else
        # See http://www.mingw.org/wiki/Posix_path_conversion.
        ./$file //verysilent //dir="root\share\InnoSetup" //noicons //tasks="" //portable=1
    fi

    # Remove unneeded files from the installation.
    ( cd root/share/InnoSetup/ && rm -fr Examples/ Compil32.exe isscint.dll )

    # Clean up.
    rm $file
fi
