#!/bin/bash

if [[ $(uname) == "Darwin" && $(uname -m) == "arm64" ]]; then
	QT="--without-qt"
else
	QT="--with-qt=qt5"
fi

./configure \
	--prefix=$PREFIX \
	--without-lua \
	--without-latex \
	--without-libcerf \
	$QT \
	--with-readline=$PREFIX \
	--without-tutorial

export GNUTERM=dumb

# Fix iconv linkage
sed -ie 's/\(^LIBS.*\)/\1 -liconv/g' src/Makefile


make -j${CPU_COUNT} PREFIX=$PREFIX

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
	make check PREFIX=$PREFIX
fi

make install PREFIX=$PREFIX
