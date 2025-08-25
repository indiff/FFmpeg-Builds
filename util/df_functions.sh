#!/bin/bash

to_df() {
    _of="${TODF:-Dockerfile}"
    printf "$@" >> "$_of"
    echo >> "$_of"
}