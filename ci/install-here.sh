#!/bin/sh

installer=$(ls -t -1 mingwGitDevEnv-*.exe | head -1)

if [ ! -f $installer ]; then
    echo "ERROR: No installer found, please build it first."
    exit 1
fi

log=$(basename $installer .exe).log
./$installer //log="$log" //verysilent //dir="mingwGitDevEnv" //noicons //portable=1
