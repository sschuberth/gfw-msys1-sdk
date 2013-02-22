#!/bin/sh

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
