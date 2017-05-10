#!/bin/bash

./configure \
	--prefix=$PREFIX \
	--without-x \
	--without-lua \
	--without-latex \
	--without-libcerf \
	--with-qt=qt4 \
	--with-readline=$PREFIX \
	--without-tutorial

export GNUTERM=dumb
make PREFIX=$PREFIX
make check PREFIX=$PREFIX
make install PREFIX=$PREFIX
