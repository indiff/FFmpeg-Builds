#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/windows-install-shared.sh

# Essential GPL-licensed libraries only for faster builds
FF_CONFIGURE+=" --enable-shared --disable-static"

# Only include the most essential GPL codecs for faster compilation
FF_CONFIGURE+=" --enable-libx264"
FF_CONFIGURE+=" --enable-libx265" 
FF_CONFIGURE+=" --enable-libfdk-aac"
FF_CONFIGURE+=" --enable-libass"
FF_CONFIGURE+=" --enable-libfreetype"

# Skip heavy optional dependencies to reduce build time
FF_CONFIGURE+=" --disable-libvpx"
FF_CONFIGURE+=" --disable-libaom"  
FF_CONFIGURE+=" --disable-librav1e"
FF_CONFIGURE+=" --disable-libsvtav1"
FF_CONFIGURE+=" --disable-libdav1d"
FF_CONFIGURE+=" --disable-libopenmpt"
FF_CONFIGURE+=" --disable-librubberband"