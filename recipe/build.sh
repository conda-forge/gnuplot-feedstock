#!/bin/bash

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

./configure \
	--prefix=$PREFIX \
	--without-lua \
	--without-latex \
	--without-libcerf \
	--with-qt=qt5 \
	--with-readline=$PREFIX \
	--without-tutorial \
	--disable-dependency-tracking

export GNUTERM=dumb
# Fix iconv linkage
sed -ie 's/\(^LIBS.*\)/\1 -liconv/g' src/Makefile
make -j${CPU_COUNT} PREFIX=$PREFIX
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check PREFIX=$PREFIX
fi
make install PREFIX=$PREFIX
