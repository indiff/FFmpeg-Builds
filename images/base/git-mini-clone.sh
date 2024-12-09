#!/bin/bash
set -xe
REPO="$1"
REF="$2"
DEST="$3"
USE_MAIN="$4"
git init "$DEST"
git -C "$DEST" remote add origin "$REPO"

if [[ $USE_MAIN == "true" ]]; then
    retry-tool git -C "$DEST" fetch --depth=1
else
    retry-tool git -C "$DEST" fetch --depth=1 origin "$REF"
fi

git -C "$DEST" config advice.detachedHead false
git -C "$DEST" checkout FETCH_HEAD
rm -rf "$DEST/.git/"