#!/bin/bash

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  # some tools are built and later executed in the build process
  # this requires a native build first
  if [[ "${build_platform}" == "linux-64" ]]; then
    # There are probably equivalent CDTs to install if your build platform
    # is something else. However, it is most common in 2023 to use the x86_64
    # hardware to cross compile for other architectures.
    mamba install --yes \
      --prefix ${BUILD_PREFIX} \
      mesa-libgl-devel-${cdt_name}-x86_64  \
      mesa-dri-drivers-${cdt_name}-x86_64 \
      libselinux-${cdt_name}-x86_64  \
      xorg-x11-proto-devel-${cdt_name}-x86_64
  fi
  (
    mkdir -p build-native
    pushd build-native
    LDFLAGS_FOR_BUILD=$(echo $LDFLAGS | sed "s?$PREFIX?$BUILD_PREFIX?g")
    LDFLAGS_LD_FOR_BUILD=$(echo $LDFLAGS_LD | sed "s?$PREFIX?$BUILD_PREFIX?g")
    ../configure --prefix="${BUILD_PREFIX}" \
     	--without-lua \
      --without-latex \
      --without-libcerf \
      --with-qt=no \
      --without-readline \
      --without-cairo \
      --disable-dependency-tracking \
      CC=$CC_FOR_BUILD \
      CXX=$CXX_FOR_BUILD \
      AR=${build_alias}-ar \
      LD=${build_alias}-ld \
      RANLIB=${build_alias}-ranlib \
      LDFLAGS="$LDFLAGS_FOR_BUILD" \
      LDFLAGS_LD="$LDFLAGS_LD_FOR_BUILD"
   
    # Fix iconv linkage
    sed -ie 's/\(^LIBS.*\)/\1 -liconv/g' ./src/Makefile
    make -j${CPU_COUNT} PREFIX=$BUILD_PREFIX
    make install PREFIX=$BUILD_PREFIX
    popd
  )
fi

if [[ $target_platform == "linux-ppc64le" ]]; then
  BUILD_WITH_QTVER=no
else
  BUILD_WITH_QTVER=qt5
fi

./configure \
	--prefix=$PREFIX \
	--without-lua \
	--without-latex \
	--without-libcerf \
	--with-qt=$BUILD_WITH_QTVER \
	--with-readline=$PREFIX \
	--disable-dependency-tracking

export GNUTERM=dumb
# Fix iconv linkage
sed -ie 's/\(^LIBS.*\)/\1 -liconv/g' src/Makefile

make -j${CPU_COUNT} PREFIX=$PREFIX
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  make check PREFIX=$PREFIX
fi
make install PREFIX=$PREFIX
