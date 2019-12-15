#!/bin/bash -e

# This script is intended only to be used in CI environments, don't use it to install libical on your system!

LIBICAL_VERSION="v3.0.7"

git clone --branch $LIBICAL_VERSION https://github.com/libical/libical.git
mkdir libical/build

cd libical/build

cmake -DWITH_CXX_BINDINGS=false \
  -DICAL_BUILD_DOCS=false \
  -DICAL_GLIB=false \
  -DCMAKE_RELEASE_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_INSTALL_LIBDIR=/usr/lib \
  -DSHARED_ONLY=true \
  ..

make
sudo make install
