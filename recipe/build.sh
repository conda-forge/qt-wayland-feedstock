#!/bin/sh
set -exou

# Clean config for dirty builds
# -----------------------------
if [[ -d qt-build ]]; then
  rm -rf qt-build
fi

mkdir qt-build
pushd qt-build

cmake ${CMAKE_ARGS} \
    ..

make -j ${CPU_COUNT}

make install
