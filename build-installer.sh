#!/bin/sh

path=$(reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 5_is1" | grep InstallLocation | cut -c 34-)
"$path/ISCC.exe" installer.iss
