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

rm -rf nginxbuild
mkdir nginxbuild

NGINX_VERSION="${NGINX_VERSION:-1.26.2}"
NGINX_VERSION="${NGINX_VERSION_OVERRIDE:-$NGINX_VERSION}"

BUILD_SCRIPT="$(mktemp)"
trap "rm -f -- '$BUILD_SCRIPT'" EXIT

cat <<EOF >"$BUILD_SCRIPT"
    set -xe
    cd /nginxbuild
    rm -rf nginx-${NGINX_VERSION} prefix

    # Download nginx source
    curl -L -o nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
    tar xzf nginx.tar.gz
    cd nginx-${NGINX_VERSION}

    # Configure nginx with minimal dependencies
    ./configure --prefix=/nginxbuild/prefix \\
        --with-cc="\$CC" \\
        --with-cc-opt="\$CFLAGS -static-libgcc" \\
        --with-ld-opt="\$LDFLAGS -static-libgcc" \\
        --crossbuild=win32 \\
        --with-http_ssl_module \\
        --with-http_v2_module \\
        --with-stream \\
        --with-stream_ssl_module \\
        --without-http_rewrite_module
    
    make -j\$(nproc)
    make install
EOF

[[ -t 1 ]] && TTY_ARG="-t" || TTY_ARG=""

docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "$PWD/nginxbuild":/nginxbuild -v "$BUILD_SCRIPT":/build.sh "$IMAGE" bash /build.sh

if [[ -n "$FFBUILD_OUTPUT_DIR" ]]; then
    mkdir -p "$FFBUILD_OUTPUT_DIR"
    package_variant nginxbuild/prefix "$FFBUILD_OUTPUT_DIR"
    [[ -n "$LICENSE_FILE" ]] && cp "nginxbuild/nginx-${NGINX_VERSION}/$LICENSE_FILE" "$FFBUILD_OUTPUT_DIR/LICENSE.txt" 2>/dev/null || true
    rm -rf nginxbuild
    exit 0
fi

mkdir -p artifacts
ARTIFACTS_PATH="$PWD/artifacts"
BUILD_NAME="nginx-${NGINX_VERSION}-${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}"

mkdir -p "nginxbuild/pkgroot/$BUILD_NAME"
package_variant nginxbuild/prefix "nginxbuild/pkgroot/$BUILD_NAME"

[[ -n "$LICENSE_FILE" ]] && cp "nginxbuild/nginx-${NGINX_VERSION}/$LICENSE_FILE" "nginxbuild/pkgroot/$BUILD_NAME/LICENSE.txt" 2>/dev/null || true

cd nginxbuild/pkgroot
if [[ "${TARGET}" == win* ]]; then
    OUTPUT_FNAME="${BUILD_NAME}.zip"
    docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "${ARTIFACTS_PATH}":/out -v "${PWD}/${BUILD_NAME}":"/${BUILD_NAME}" -w / "$IMAGE" zip -9 -r "/out/${OUTPUT_FNAME}" "$BUILD_NAME"
else
    OUTPUT_FNAME="${BUILD_NAME}.tar.xz"
    docker run --rm -i $TTY_ARG "${UIDARGS[@]}" -v "${ARTIFACTS_PATH}":/out -v "${PWD}/${BUILD_NAME}":"/${BUILD_NAME}" -w / "$IMAGE" tar cJf "/out/${OUTPUT_FNAME}" "$BUILD_NAME"
fi
cd -

rm -rf nginxbuild

if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "build_name=${BUILD_NAME}" >> "$GITHUB_OUTPUT"
    echo "${OUTPUT_FNAME}" > "${ARTIFACTS_PATH}/${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}.txt"
fi
