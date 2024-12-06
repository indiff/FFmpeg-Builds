#!/bin/bash

SCRIPT_REPO="https://svn.xvid.org/trunk/xvidcore"
SCRIPT_REV="2200"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}
# svn --non-interactive checkout --username 'anonymous' --password '' 'https://svn.xvid.org/trunk/xvidcore@2200' xvid
# svn --non-interactive checkout --username 'anonymous' --password '' https://svn.xvid.org/trunk/xvidcore xvid
ffbuild_dockerdl() {
    # https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.gz
    # echo "retry-tool sh -c \"rm -rf xvidcore xvidcore-1.3.7.tar.gz && wget https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.gz && tar xvf xvidcore-1.3.7.tar.gz && rm -f xvidcore-1.3.7.tar.gz && mv xvidcore xvid\" && cd xvid"
    #echo "retry-tool sh -c \"rm -rf xvid && wget --no-check-certificate -q https://github.com/indiff/FFmpeg-Builds/releases/download/xvid2200/xvid2200_cache.zip && unzip xvid2200_cache.zip -d xvid && rm -f xvid2200_cache.zip\" && cd xvid"
    #svn forbidden can not checkout
    echo "retry-tool sh -c \"rm -rf xvid && svn --non-interactive checkout --username 'anonymous' --password '' '${SCRIPT_REPO}@${SCRIPT_REV}' xvid\" && cd xvid"
}

ffbuild_dockerbuild() {
    cd build/generic

    # The original code fails on a two-digit major...
    sed -i\
        -e 's/GCC_MAJOR=.*/GCC_MAJOR=10/' \
        -e 's/GCC_MINOR=.*/GCC_MINOR=0/' \
        configure.in
     chmod +x bootstrap.sh

    ./bootstrap.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi
    chmod +x configure

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    if [[ $TARGET == win* ]]; then
        rm "$FFBUILD_PREFIX"/{bin/libxvidcore.dll,lib/libxvidcore.dll.a}
    elif [[ $TARGET == linux* ]]; then
        rm "$FFBUILD_PREFIX"/lib/libxvidcore.so*
    fi
}

ffbuild_configure() {
    echo --enable-libxvid
}

ffbuild_unconfigure() {
    echo --disable-libxvid
}
