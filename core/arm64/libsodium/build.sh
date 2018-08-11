#!/bin/bash

set -e 

mkdir -p /tmp/libsodium
cd /tmp/libsodium
wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz
gpg --import /builder/libsodium/libsodium.gpg.pub
gpg --verify /builder/libsodium/libsodium-1.0.16.tar.gz.sig ./libsodium-1.0.16.tar.gz
tar -xvf ./libsodium-1.0.16.tar.gz
rm libsodium-1.0.16.tar.gz
cd libsodium-1.0.16

TARGET=aarch64-linux-android
export CFLAGS="-fPIC -O2"
export CC="${TARGET}-gcc"
export PATH="$PATH:/opt/gcc-arm64-android/bin"

./configure \
        --prefix=/opt/libsodium/${TARGET} \
        --with-sysroot=/opt/libsodium/${TARGET}/sysroot \
        --host=aarch64-linux-android \
        --disable-soname-versions \
        --enable-static \
        --disable-shared

make
make install

