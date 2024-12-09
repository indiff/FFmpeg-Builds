#!/bin/bash

USE_MAIN="$1"

default_dl() {
    echo "git-mini-clone \"$SCRIPT_REPO\" \"$SCRIPT_COMMIT\" \"$1\" \"$USE_MAIN\""
}

ffbuild_dockerdl() {
    default_dl .
}
