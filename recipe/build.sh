#!/bin/bash

export CXXFLAGS="$CXXFLAGS -std=c++11"

if [ "$(uname)" == "Linux" ]
then
	export LDFLAGS="$LDFLAGS -L $PREFIX/lib -liconv"
fi


# fix build error in macOS with system compilers:
# - qtterminal/qt_term.cpp:51:10: fatal error: 'QtCore' file not found
#- #include <QtCore>

if [ "$(uname)" == "Darwin" ]
then
	export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/qt"
	export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/qt/QtCore"
	export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/qt/QtGui"
	export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/qt/QtWidgets"
	export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/qt/QtPrintSupport"
	export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/qt/QtSvg"
	export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/qt/QtNetwork"
fi

./configure \
	--prefix=$PREFIX \
	--without-x \
	--without-lua \
	--without-latex \
	--without-libcerf \
	--with-qt=qt5 \
	--with-readline=$PREFIX \
	--without-tutorial

export GNUTERM=dumb
make PREFIX=$PREFIX
make check PREFIX=$PREFIX
make install PREFIX=$PREFIX
