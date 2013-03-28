#!/bin/bash

SOURCE=${BASH_SOURCE[0]}
source $(dirname $SOURCE)/preexec.bash

function preexec () {
    ext="${1##*.}"

    if [ "$ext" = "bat" ] || [ "$ext" = "cmd" ]; then
        cmd //c "$1"
        false
    fi
}

preexec_install
