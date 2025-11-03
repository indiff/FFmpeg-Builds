#!/bin/bash
set -xe
shopt -s globstar
cd "$(dirname "$0")"
source util/vars.sh

source "variants/${TARGET}-${VARIANT}.sh"

for addin in ${ADDINS[*]}; do
    source "addins/${addin}.sh"
done

if docker info -f "{{println .SecurityOptions}}" | grep rootless >/dev/null 2>&1; then
    UIDARGS=()
else
    UIDARGS=( -u "$(id -u):$(id -g)" )
fi

rm -rf ffbuild
mkdir ffbuild

NGINX_VERSION="${NGINX_VERSION:-1.24.0}"
NGINX_REPO="${NGINX_REPO:-http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz}"
PCRE_VERSION="${PCRE_VERSION:-10.42}"
PCRE_REPO="${PCRE_REPO:-https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VERSION}/pcre2-${PCRE_VERSION}.tar.gz}"

BUILD_SCRIPT="$(mktemp)"
trap "rm -f -- '$BUILD_SCRIPT'" EXIT

cat <<EOF >"$BUILD_SCRIPT"
    set -xe
    cd /ffbuild
    rm -rf nginx prefix pcre2-src

    # Download and extract nginx
    wget -O nginx.tar.gz '$NGINX_REPO'
    tar xzf nginx.tar.gz
    mv nginx-* nginx
    
    # Download and extract PCRE2 source (nginx needs source for Windows builds)
    wget -O pcre2.tar.gz '$PCRE_REPO'
    tar xzf pcre2.tar.gz
    mv pcre2-* pcre2-src
    
    cd nginx

    # Configure nginx for Windows cross-compilation
    # Nginx auto-detects the platform from CC, so we set it appropriately
    export NGX_SYSTEM=WIN32
    export NGX_RELEASE=\$(uname -r)
    export NGX_MACHINE=\$(uname -m)
    
    auto/configure \\
        --prefix= \\
        --conf-path=conf/nginx.conf \\
        --pid-path=logs/nginx.pid \\
        --http-log-path=logs/access.log \\
        --error-log-path=logs/error.log \\
        --sbin-path=nginx.exe \\
        --http-client-body-temp-path=temp/client_body_temp \\
        --http-proxy-temp-path=temp/proxy_temp \\
        --http-fastcgi-temp-path=temp/fastcgi_temp \\
        --http-scgi-temp-path=temp/scgi_temp \\
        --http-uwsgi-temp-path=temp/uwsgi_temp \\
        --with-cc="\$CC" \\
        --with-cc-opt="\$CFLAGS -I/opt/ffbuild/include -DFD_SETSIZE=1024" \\
        --with-ld-opt="\$LDFLAGS -L/opt/ffbuild/lib" \\
        --with-http_ssl_module \\
        --with-openssl=/opt/ffbuild \\
        --with-pcre=../pcre2-src \\
        --with-pcre-opt="-DPCRE2_STATIC" \\
        --with-zlib=/opt/ffbuild \\
        --with-select_module \\
        --without-http_rewrite_module \\
        --without-http_gzip_module
    
    make -j\$(nproc)
    make install DESTDIR=/ffbuild/prefix
EOF

[[ -t 1 ]] && TTY_ARG="-t" || TTY_ARG=""

docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "$PWD/ffbuild":/ffbuild -v "$BUILD_SCRIPT":/build.sh "$IMAGE" bash /build.sh

if [[ -n "$FFBUILD_OUTPUT_DIR" ]]; then
    mkdir -p "$FFBUILD_OUTPUT_DIR"
    package_variant ffbuild/prefix "$FFBUILD_OUTPUT_DIR"
    [[ -n "$LICENSE_FILE" ]] && cp "ffbuild/nginx/$LICENSE_FILE" "$FFBUILD_OUTPUT_DIR/LICENSE.txt"
    rm -rf ffbuild
    exit 0
fi

mkdir -p artifacts
ARTIFACTS_PATH="$PWD/artifacts"
BUILD_NAME="nginx-${NGINX_VERSION}-${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}"

mkdir -p "ffbuild/pkgroot/$BUILD_NAME"
package_variant ffbuild/prefix "ffbuild/pkgroot/$BUILD_NAME"

[[ -n "$LICENSE_FILE" ]] && cp "ffbuild/nginx/$LICENSE_FILE" "ffbuild/pkgroot/$BUILD_NAME/LICENSE.txt"

cd ffbuild/pkgroot
if [[ "${TARGET}" == win* ]]; then
    OUTPUT_FNAME="${BUILD_NAME}.zip"
    docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "${ARTIFACTS_PATH}":/out -v "${PWD}/${BUILD_NAME}":"/${BUILD_NAME}" -w / "$IMAGE" zip -9 -r "/out/${OUTPUT_FNAME}" "$BUILD_NAME"
else
    OUTPUT_FNAME="${BUILD_NAME}.tar.xz"
    docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "${ARTIFACTS_PATH}":/out -v "${PWD}/${BUILD_NAME}":"/${BUILD_NAME}" -w / "$IMAGE" tar cJf "/out/${OUTPUT_FNAME}" "$BUILD_NAME"
fi
cd -

rm -rf ffbuild

if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "build_name=${BUILD_NAME}" >> "$GITHUB_OUTPUT"
    echo "${OUTPUT_FNAME}" > "${ARTIFACTS_PATH}/${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}.txt"
fi
