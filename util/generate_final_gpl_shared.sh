#!/bin/bash
set -e
cd "$(dirname "$0")/.."

TARGET="$1"

if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 <target>"
    exit 1
fi

VARIANT="gpl-shared"
source util/vars.sh

# Generate final Dockerfile that combines all stages
rm -f Dockerfile.final
export TODF="Dockerfile.final"

./util/df_functions.sh to_df "FROM ${REGISTRY}/${REPO}/base-${TARGET}:latest AS base"

# Copy from each stage
for STAGE in stage1 stage2 stage3; do
    STAGE_IMAGE="${REGISTRY}/${REPO}/${TARGET}-gpl-shared-${STAGE}:latest"
    ./util/df_functions.sh to_df "FROM $STAGE_IMAGE AS $STAGE"
done

# Combine all stages into final image
./util/df_functions.sh to_df "FROM base AS final"
./util/df_functions.sh to_df "COPY --link --from=stage1 /opt/ffbuild/. /opt/ffbuild/"
./util/df_functions.sh to_df "COPY --link --from=stage2 /opt/ffbuild/. /opt/ffbuild/"
./util/df_functions.sh to_df "COPY --link --from=stage3 /opt/ffbuild/. /opt/ffbuild/"

# Add final configuration environment
source "variants/${TARGET}-${VARIANT}.sh"

for addin in "${ADDINS[@]:-}"; do
    source "addins/${addin}.sh"
done

# Build configure flags
FF_CONFIGURE=""
FF_CFLAGS=""
FF_CXXFLAGS=""
FF_LDFLAGS=""
FF_LDEXEFLAGS=""
FF_LIBS=""

for script in scripts.d/**/*.sh; do
    if [[ -f "$script" ]]; then
        source "$script"
        if ffbuild_enabled 2>/dev/null; then
            FF_CONFIGURE+=" $(ffbuild_configure 2>/dev/null || echo "")"
            FF_CFLAGS+=" $(ffbuild_cflags 2>/dev/null || echo "")"
            FF_CXXFLAGS+=" $(ffbuild_cxxflags 2>/dev/null || echo "")"
            FF_LDFLAGS+=" $(ffbuild_ldflags 2>/dev/null || echo "")"
            FF_LDEXEFLAGS+=" $(ffbuild_ldexeflags 2>/dev/null || echo "")"
            FF_LIBS+=" $(ffbuild_libs 2>/dev/null || echo "")"
        fi
    fi
done

# Clean up environment variables
FF_CONFIGURE="$(echo "$FF_CONFIGURE" | xargs 2>/dev/null || echo "")"
FF_CFLAGS="$(echo "$FF_CFLAGS" | xargs 2>/dev/null || echo "")"
FF_CXXFLAGS="$(echo "$FF_CXXFLAGS" | xargs 2>/dev/null || echo "")"
FF_LDFLAGS="$(echo "$FF_LDFLAGS" | xargs 2>/dev/null || echo "")"
FF_LDEXEFLAGS="$(echo "$FF_LDEXEFLAGS" | xargs 2>/dev/null || echo "")"
FF_LIBS="$(echo "$FF_LIBS" | xargs 2>/dev/null || echo "")"

./util/df_functions.sh to_df "ENV \\\\"
./util/df_functions.sh to_df "    FF_CONFIGURE=\"$FF_CONFIGURE\" \\\\"
./util/df_functions.sh to_df "    FF_CFLAGS=\"$FF_CFLAGS\" \\\\"
./util/df_functions.sh to_df "    FF_CXXFLAGS=\"$FF_CXXFLAGS\" \\\\"
./util/df_functions.sh to_df "    FF_LDFLAGS=\"$FF_LDFLAGS\" \\\\"
./util/df_functions.sh to_df "    FF_LDEXEFLAGS=\"$FF_LDEXEFLAGS\" \\\\"
./util/df_functions.sh to_df "    FF_LIBS=\"$FF_LIBS\""

echo "Generated Dockerfile.final for $TARGET gpl-shared"