#!/bin/bash
# Optimization script for gpl-shared builds
# This script optimizes compilation flags and parallel processing for faster builds

set -e

# Only apply optimizations for gpl-shared variants
if [[ "$VARIANT" != *"gpl-shared"* ]]; then
    exit 0
fi

echo "Applying gpl-shared build optimizations..."

# Set aggressive compilation optimization flags
export MAKEFLAGS="-j$(nproc)"
export CFLAGS="-O2 -pipe -g0 -DNDEBUG"
export CXXFLAGS="-O2 -pipe -g0 -DNDEBUG"
export LDFLAGS="-s"  # Strip symbols to reduce binary size and link time

# Skip unnecessary features in dependencies to speed up compilation
export FFBUILD_SKIP_TESTS=1
export FFBUILD_SKIP_DOCS=1
export FFBUILD_SKIP_EXAMPLES=1

# Use faster linker if available
if command -v mold >/dev/null 2>&1; then
    export LDFLAGS="$LDFLAGS -fuse-ld=mold"
elif command -v lld >/dev/null 2>&1; then
    export LDFLAGS="$LDFLAGS -fuse-ld=lld"
fi

# Enable ccache for faster rebuilds if available
if command -v ccache >/dev/null 2>&1; then
    export CC="ccache $CC"
    export CXX="ccache $CXX"
    export CCACHE_DIR="/tmp/ccache"
    export CCACHE_MAXSIZE="2G"
    ccache -s || true
fi

# Optimize specific heavy dependencies
optimize_dependency() {
    local dep="$1"
    case "$dep" in
        "x264"|"x265"|"aom"|"dav1d"|"libvpx")
            # These are CPU-intensive video codecs, reduce optimization level for faster compilation
            export CFLAGS="-O1 -pipe -g0 -DNDEBUG"
            export CXXFLAGS="-O1 -pipe -g0 -DNDEBUG"
            ;;
        "libjxl"|"libplacebo"|"openmpt")
            # These have heavy C++ templates, optimize for compile time
            export CXXFLAGS="-O1 -pipe -g0 -DNDEBUG -ftemplate-backtrace-limit=0"
            ;;
    esac
}

echo "Build optimizations applied for gpl-shared variant"