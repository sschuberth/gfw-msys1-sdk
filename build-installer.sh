#!/bin/sh

iscc="root/share/InnoSetup/ISCC.exe"
if [ ! -f "$iscc" ]; then
    path=$(reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 5_is1" 2> /dev/null | grep InstallLocation | cut -c 34-)
    iscc="$path/ISCC.exe"
fi

if [ -f "$iscc" ]; then
    wine=$(type -p wine)
    APP_VERSION=$(git describe --tags) $wine $iscc installer/installer.iss
else
    echo "ERROR: Unable to find an Inno Setup installation."
    exit 1
fi
