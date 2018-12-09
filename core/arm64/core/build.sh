#!/bin/bash

TARGET=target/aarch64-linux-android/release/libturtl_core.so

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

BUILD_TYPE="release"
if [ "${DEBUG}" == "1" ]; then
	BUILD_TYPE="all"
fi

export PATH=$PATH:/opt/gcc-arm64-android/bin
make \
    SODIUM_LIB_DIR=/opt/libsodium/aarch64-linux-android/lib \
    OPENSSL_LIB_DIR=/opt/openssl/aarch64-linux-android/lib \
    OPENSSL_INCLUDE_DIR=/opt/openssl/aarch64-linux-android/include \
    CARGO_BUILD_ARGS="${CARGO_BUILD_ARGS} --target aarch64-linux-android" \
    FEATURES="build-jni sqlite-static" \
	${BUILD_TYPE}

if [ "${OUTFILE}" != "" ]; then
	echo "- Copy ${TARGET} -> ${OUTFILE}"
	cp "${TARGET}" "${OUTFILE}"
fi

