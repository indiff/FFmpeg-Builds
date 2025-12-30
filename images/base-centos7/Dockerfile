ARG GH_REPO=ghcr.io/qwop/ffmpeg-builds
FROM $GH_REPO/base:latest


ARG HOST_TRIPLE="x86_64-centos7-linux-gnu"
ARG GCC_VERSION="15"

COPY *.py .
RUN mkdir /config-${HOST_TRIPLE}
RUN python3 gen-cmake-toolchain.py ${HOST_TRIPLE} /config-${HOST_TRIPLE}/${HOST_TRIPLE}.toolchain.cmake
RUN python3 gen-conan-profile.py ${HOST_TRIPLE} ${GCC_VERSION} /config-${HOST_TRIPLE}/${HOST_TRIPLE}.profile.conan

# Install autoconf
RUN wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.gz -O- | tar xz && \
    cd autoconf-2.72 && \
    ./configure --prefix=/opt/autoconf && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf autoconf-2.72
ENV PATH=/opt/autoconf/bin:${PATH}

# RUN --mount=src=ct-ng-config,dst=/.config \
#     git clone --filter=blob:none https://github.com/crosstool-ng/crosstool-ng.git /ct-ng && cd /ct-ng && \
#     ./bootstrap && \
#     ./configure --enable-local && \
#     make -j$(nproc) && \
#     cp /.config .config && \
#     ./ct-ng build && \
#     cd / && \
#     rm -rf ct-ng

# Build crosstool-ng
RUN git clone -b master --single-branch \
        https://github.com/crosstool-ng/crosstool-ng.git && \
    cd crosstool-ng && \
    git checkout f390dba6c73845389a3217169402d95a837fcee8 && \
    git show --summary && \
    ./bootstrap && \
    mkdir build && cd build && \
    ../configure --prefix=/opt/ct-ng && \
    make -j$(($(nproc) * 2)) && \
    make install &&  \
    cd /opt/ct-ng && rm -rf crosstool-ng

# Patches
# https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=280707&p=1700861#p1700861
RUN wget https://ftp.debian.org/debian/pool/main/b/binutils/binutils_2.45-3.debian.tar.xz -O- | \
    tar xJ debian/patches/129_multiarch_libpath.patch && \
    mkdir -p patches/binutils/2.45 && \
    mv debian/patches/129_multiarch_libpath.patch patches/binutils/2.45 && \
    rm -rf debian


ARG PKG_VERSION
# Build the toolchain
COPY ${HOST_TRIPLE}.defconfig .
COPY ${HOST_TRIPLE}.env .
RUN [ -n "${GCC_VERSION}" ] && { echo "CT_GCC_V_${GCC_VERSION}=y" >> ${HOST_TRIPLE}.defconfig; }
RUN [ -n "${PKG_VERSION}" ] && { echo "CT_TOOLCHAIN_PKGVERSION=\"qwop/FFmpeg-Builds@${PKG_VERSION}\"" >> ${HOST_TRIPLE}.defconfig; }
RUN cp ${HOST_TRIPLE}.defconfig defconfig && ct-ng defconfig
RUN . ./${HOST_TRIPLE}.env && \
    ct-ng build || { cat build.log && false; } && rm -rf .build    


# Prepare "cross" environment to heavily favour static builds
RUN \
    find /opt/ct-ng -type l \
        -and -name '*.so' \
        -and -not -ipath '*plugin*' \
        -and -not -name 'libdl.*' \
        -and -not -name 'libc.*' \
        -and -not -name 'libm.*' \
        -and -not -name 'libmvec.*' \
        -and -not -name 'librt.*' \
        -and -not -name 'libpthread.*' \
        -delete && \
    find /opt/ct-ng \
        -name 'libdl.a' \
        -or -name 'libc.a' \
        -or -name 'libm.a' \
        -or -name 'libmvec.a' \
        -or -name 'librt.a' \
        -or -name 'libpthread.a' \
        -delete && \
    mkdir /opt/ffbuild

ENV FFBUILD_TOOLCHAIN=x86_64-ffbuild-linux-gnu \
    FFBUILD_RUST_TARGET="x86_64-unknown-linux-gnu"

RUN \
    rustup default nightly && \
    echo "[unstable]\ntarget-applies-to-host = true\nhost-config = true\n" > "$CARGO_HOME"/config.toml && \
    echo "[target.$FFBUILD_RUST_TARGET]\nlinker = \"${FFBUILD_TOOLCHAIN}-gcc\"\nar = \"${FFBUILD_TOOLCHAIN}-gcc-ar\"\n" >> "$CARGO_HOME"/config.toml && \
    echo "[target.host]\nlinker = \"gcc\"\nar = \"ar\"\n" >> "$CARGO_HOME"/config.toml

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ADD gen-implib.sh /usr/bin/gen-implib
RUN git clone --filter=blob:none --depth=1 https://github.com/yugr/Implib.so /opt/implib

ENV PATH="/opt/ct-ng/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- --arch=x86_64 --target-os=linux" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_DESTDIR=/opt/ffdest \
    FFBUILD_DESTPREFIX=/opt/ffdest/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    CC="${FFBUILD_TOOLCHAIN}-gcc" \
    CXX="${FFBUILD_TOOLCHAIN}-g++" \
    LD="${FFBUILD_TOOLCHAIN}-ld" \
    AR="${FFBUILD_TOOLCHAIN}-gcc-ar" \
    RANLIB="${FFBUILD_TOOLCHAIN}-gcc-ranlib" \
    NM="${FFBUILD_TOOLCHAIN}-gcc-nm" \
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fstack-clash-protection -pthread" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fstack-clash-protection -pthread" \
    LDFLAGS="-fuse-ld=mold  -Wl,--strip-all -Wl,--gc-sections -static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong -fstack-clash-protection -Wl,-z,relro,-z,now -pthread -lm" \
    STAGE_CFLAGS="-fvisibility=hidden -fno-semantic-interposition" \
    STAGE_CXXFLAGS="-fvisibility=hidden -fno-semantic-interposition"

RUN ${HOST_TRIPLE}-g++ --version