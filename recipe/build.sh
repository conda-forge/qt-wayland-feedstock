#!/bin/sh

if test "$CONDA_BUILD_CROSS_COMPILATION" = "1"
then
  if [[ "${build_platform}" == "linux-64" ]]; then
    # There are probably equivalent CDTs to install if your build platform
    # is something else. However, it is most common in 2023 to use the x86_64
    # hardware to cross compile for other architectures.
    mamba install --yes \
      --prefix ${BUILD_PREFIX} \
      mesa-libgl-devel-${cdt_name}-x86_64  \
      mesa-libegl-devel-${cdt_name}-x86_64 \
      mesa-dri-drivers-${cdt_name}-x86_64  \
      libdrm-devel-${cdt_name}-x86_64 \
      libglvnd-glx-${cdt_name}-x86_64 \
      libglvnd-egl-${cdt_name}-x86_64
  fi
  (
    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}
    export CFLAGS=${CFLAGS//$PREFIX/$BUILD_PREFIX}
    export CXXFLAGS=${CXXFLAGS//$PREFIX/$BUILD_PREFIX}

    # hide host libs
    mkdir -p $BUILD_PREFIX/${HOST}
    mv $BUILD_PREFIX/${HOST} _hidden

    cmake -LAH -G "Ninja" \
      -DCMAKE_PREFIX_PATH=${BUILD_PREFIX} \
      -DCMAKE_IGNORE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_FIND_FRAMEWORK=LAST \
      -DCMAKE_INSTALL_RPATH:STRING=${BUILD_PREFIX}/lib \
      -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
      -DCMAKE_RANLIB=$BUILD_PREFIX/bin/${CONDA_TOOLCHAIN_BUILD}-ranlib \
      -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX} \
    -B build_native .
    cmake --build build_native --target install
    mv _hidden $BUILD_PREFIX/${HOST}
  )
  rm -r build_native
  CMAKE_ARGS="${CMAKE_ARGS} -DQT_HOST_PATH=${BUILD_PREFIX}"
fi

cmake -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DQT_HOST_PATH=${PREFIX} \
  -B build ${CMAKE_ARGS} .
cmake --build build --target install

