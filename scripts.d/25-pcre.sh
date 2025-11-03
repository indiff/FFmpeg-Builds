#!/bin/bash

SCRIPT_REPO="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz"
SCRIPT_COMMIT="pcre2-10.42"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-static
        --disable-shared
        --enable-jit
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    return 0
}

ffbuild_unconfigure() {
    return 0
}
