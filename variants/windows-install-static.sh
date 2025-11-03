#!/bin/bash

package_variant() {
    IN="$1"
    OUT="$2"

    mkdir -p "$OUT"/bin
    # Copy nginx executables
    if [ -d "$IN"/sbin ]; then
        cp "$IN"/sbin/* "$OUT"/bin 2>/dev/null || true
    fi
    if [ -d "$IN"/bin ]; then
        cp "$IN"/bin/* "$OUT"/bin 2>/dev/null || true
    fi

    # Copy nginx configuration and html files
    if [ -d "$IN"/conf ]; then
        mkdir -p "$OUT/conf"
        cp -r "$IN"/conf/* "$OUT"/conf 2>/dev/null || true
    fi
    
    if [ -d "$IN"/html ]; then
        mkdir -p "$OUT/html"
        cp -r "$IN"/html/* "$OUT"/html 2>/dev/null || true
    fi
}
