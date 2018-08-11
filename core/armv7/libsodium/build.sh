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

TARGET=arm-linux-androideabi
export CC="${TARGET}-gcc"
export PATH="$PATH:/opt/gcc-armv7-android/bin"
export TARGET_ARCH=armv7-a
export CFLAGS="-Os -fPIC -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -marm -march=${TARGET_ARCH}"

./configure \
        --prefix=/opt/libsodium/${TARGET} \
        --with-sysroot=/opt/libsodium/${TARGET}/sysroot \
        --host=arm-linux-androideabi \
        --disable-soname-versions \
        --enable-static \
        --disable-shared || exit 1

make
make install

