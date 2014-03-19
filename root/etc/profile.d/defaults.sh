#!/bin/bash

# Enable Git completion.
f=/mingw/share/git-core/git-completion.bash
[ -r "$f" ] && source "$f"

# Define a Git prompt.
f=/mingw/share/git-core/git-prompt.sh
[ -r "$f" ] && source "$f"

if type -t __git_ps1 >/dev/null; then
    export PROMPT_COMMAND='__git_ps1 "\n\[\033[33m\]\w\[\033[0m\]\[\033[32m\]" "\[\033[0m\]\n$ "'
fi

# Make vim the default editor as we do not ship vi.
export EDITOR=vim

# For some reason MSYS converts all Windows environment variables to upper case,
# but some programs require the proxy environment variables to be in lower case.
if [ -z "$http_proxy" ] && [ -n "$HTTP_PROXY" ]; then
    export http_proxy=$HTTP_PROXY
fi

if [ -z "$https_proxy" ]; then
    if [ -n "$HTTPS_PROXY" ]; then
        export https_proxy=$HTTPS_PROXY
    elif [ -n "$http_proxy" ]; then
        export https_proxy=$http_proxy
    fi
fi

if [ -z "$ftp_proxy" ]; then
    if [ -n "$FTP_PROXY" ]; then
        export ftp_proxy=$FTP_PROXY
    elif [ -n "$http_proxy" ]; then
        export ftp_proxy=$http_proxy
    fi
fi

if [ -z "$ftps_proxy" ]; then
    if [ -n "$FTPS_PROXY" ]; then
        export ftps_proxy=$FTPS_PROXY
    elif [ -n "$ftp_proxy" ]; then
        export ftps_proxy=$ftp_proxy
    fi
fi

# Allow to execute *.bat and *.cmd files directly without the need to
# manually prefix each call with "cmd //c".
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
