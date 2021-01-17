#!/bin/bash

./configure \
	--prefix=$PREFIX \
	--without-lua \
	--without-latex \
	--without-libcerf \
	--with-qt=qt5 \
	--with-readline=$PREFIX \
	--without-tutorial

export GNUTERM=dumb
make -j${CPU_COUNT} PREFIX=$PREFIX
make check PREFIX=$PREFIX
make install PREFIX=$PREFIX
