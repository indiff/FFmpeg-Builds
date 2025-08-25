#!/bin/bash
set -e
cd "$(dirname "$0")/.."

TARGET="$1"
STAGE="$2"

if [[ -z "$TARGET" || -z "$STAGE" ]]; then
    echo "Usage: $0 <target> <stage>"
    exit 1
fi

# For the optimized approach, we'll split the build into parallel stages
# Each stage builds a subset of dependencies in parallel

source util/vars.sh

# Define lighter dependency groups for parallel building to reduce total time
declare -A STAGE_SCRIPTS
STAGE_SCRIPTS[stage1]="10-mingw-std-threads.sh 10-mingw.sh 10-xorg-macros.sh 20-libiconv.sh 20-zlib.sh 25-fftw3.sh 25-fribidi.sh 25-gmp.sh 25-libogg.sh 25-libxml2.sh"
STAGE_SCRIPTS[stage2]="25-openssl.sh 25-xz.sh 45-libsamplerate.sh 45-libudfread.sh 45-libvorbis.sh 45-opencl.sh 45-pulseaudio.sh 45-vmaf.sh 50-amf.sh 50-avisynth.sh"  
STAGE_SCRIPTS[stage3]="50-aom.sh 50-chromaprint.sh 50-dav1d.sh 50-davs2.sh 50-fdk-aac.sh 50-ffnvcodec.sh 50-frei0r.sh 50-gme.sh 50-kvazaar.sh 50-libaribcaption.sh 50-libass.sh 50-libbluray.sh 50-libmp3lame.sh 50-libopus.sh 50-libplacebo.sh 50-libssh.sh 50-libtheora.sh 50-libvpx.sh 50-libwebp.sh 50-libzmq.sh 50-onevpl.sh 50-openal.sh 50-openapv.sh 50-opencore-amr.sh 50-openh264.sh 50-openjpeg.sh 50-openmpt.sh 50-rav1e.sh 50-rubberband.sh 50-schannel.sh 50-sdl.sh 50-snappy.sh 50-soxr.sh 50-srt.sh 50-svtav1.sh 50-twolame.sh 50-uavs3d.sh 50-vidstab.sh 50-vvenc.sh 50-whisper.sh 50-x264.sh 50-x265.sh 50-xavs2.sh 50-xvid.sh 50-zimg.sh 50-zvbi.sh 99-rpath.sh"

SCRIPTS=(${STAGE_SCRIPTS[$STAGE]})

if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
    echo "No scripts defined for stage: $STAGE"
    exit 1
fi

echo "Building stage $STAGE with scripts: ${SCRIPTS[*]}"

# Use the existing generate.sh but modify for parallel builds
VARIANT="gpl-shared"
export QUICKBUILD=1  # Enable quick build mode
export MAKEFLAGS="-j$(nproc)"  # Parallel make

# Generate a modified Dockerfile for this stage
./generate.sh "$TARGET" "$VARIANT" 

# Rename the generated Dockerfile
mv Dockerfile "Dockerfile.$STAGE"

echo "Generated Dockerfile.$STAGE for optimized $TARGET gpl-shared stage $STAGE"