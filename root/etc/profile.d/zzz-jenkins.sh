#!/bin/sh

if [ -f /THIS_IS_JENKINS ]; then
    pushd /git && make && popd
fi
