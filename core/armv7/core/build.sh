#!/bin/bash

TARGET=target/armv7-linux-androideabi/release/libturtl_core.so

# ------------------------------------------------------------------------------

OUTFILE=$1

set -e

source ~/.cargo/env

mkdir -p /turtl
cd /turtl
if [ ! -d core ]; then
	git clone https://github.com/turtl/core-rs core
fi
cd core
git pull
cp /builder/core/vars.mk .

export PATH=$PATH:/opt/gcc-armv7-android/bin
make \
	SODIUM_LIB_DIR=/opt/libsodium/arm-linux-androideabi/lib \
	OPENSSL_LIB_DIR=/opt/openssl/armv7-linux-android/lib \
	OPENSSL_INCLUDE_DIR=/opt/openssl/armv7-linux-android/include \
	CARGO_BUILD_ARGS="${CARGO_BUILD_ARGS} --target armv7-linux-androideabi" \
	FEATURES="build-jni sqlite-static" \
	release

if [ "${OUTFILE}" != "" ]; then
	echo "- Copy ${TARGET} -> ${OUTFILE}"
	cp "${TARGET}" "${OUTFILE}"
fi

