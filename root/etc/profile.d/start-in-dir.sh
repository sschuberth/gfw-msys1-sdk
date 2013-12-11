#!/bin/sh

# Overload "cd" just for the first use after this function is defined, which would be the
#     cd "$HOME"
# call at the end of /etc/profile. With this trick we can start in the root instead of $HOME.
function cd() {
    unset -f cd
    [ -n "$START_DIR" ] && cd "$START_DIR" || cd /
}
