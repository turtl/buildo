#!/bin/bash

set -e

# ------------------------------------------------------------------------------
# config section
# ------------------------------------------------------------------------------
# location of the gcc toolchain compilers we need
PREFIX_GCC_ARM64=/opt/gcc-arm64-android
PREFIX_GCC_ARMV7=/opt/gcc-armv7-android

# feel free to change
TMP=/tmp/turtl-build
# ------------------------------------------------------------------------------

mkdir -p ${TMP}
pwd=$(pwd)

# set up our deps. obviously feel free to ignore/preinstall.
function setup_deps() {
	apt-get update && \
	mkdir -p /usr/share/man/man1 && \
	apt-get install -y \
		bash \
		build-essential \
		curl \
		default-jre \
		git \
		gnupg2 \
		python \
		unzip \
		wget \
		xutils-dev
}

# sets up a GCC toolchain for either arm64/armv7, which rust uses to compile the
# core for us. these may already be installed on the build machine. if so,
# feel free to disable this.
#
# that said, it might help to have these specific versions of the GCC toolchains
# on the build system (feel free to change PREFIX_GCC_* up top if they are in a
# different location).
function setup_toolchain() {
	mkdir -p ${TMP}/android-sdk
	pushd ${TMP}/android-sdk
	wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
	unzip sdk-tools-linux-4333796.zip
	cd tools
	echo 'y' | ./bin/sdkmanager 'platforms;android-23'
	cd ..
	# note that we can't use the latest NDK because it doesn't include GCC,
	# and we need a GCC toolchain to compile openssl
	wget https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip
	unzip android-ndk-r17c-linux-x86_64.zip
	mv android-ndk-r17c ndk-bundle
	cd ndk-bundle
	if [ ! -d ${PREFIX_GCC_ARMV7} ]; then
		./build/tools/make_standalone_toolchain.py --arch arm --api 23 --install-dir ${PREFIX_GCC_ARMV7}
	fi
	if [ ! -d ${PREFIX_GCC_ARM64} ]; then
		./build/tools/make_standalone_toolchain.py --arch arm64 --api 23 --install-dir ${PREFIX_GCC_ARM64}
	fi
	popd
	#rm -rf ${TMP}/android-sdk
}

# sets up rust with the targets we need for compilation. like the apt deps, this
# can probably be removed from this and just set up once.
#
# our system uses rust 1.28, but it will almost certainly work with earlier
# versions.
function setup_rust() {
	curl https://sh.rustup.rs -sSf > ${TMP}/rustup.sh
	chmod 755 ${TMP}/rustup.sh
	${TMP}/rustup.sh -y --default-toolchain none

	source ~/.cargo/env
	# this sets up some of the target <--> toolchain mappings for the rust compiler.
	# these may exist in some capacity on the build machine already, so feel free
	# to set these manually and delete the section in `setup_rust()` that uses it
	cat ${pwd}/rust/cargo-config >> ~/.cargo/config
	rustup toolchain add 1.28.0
	rustup default 1.28.0
	# need both of these
	rustup target add aarch64-linux-android
	rustup target add armv7-linux-androideabi
}

# download/verify/unzip libsodium
function setup_libsodium() {
	mkdir -p ${TMP}/libsodium
	pushd ${TMP}/libsodium
	wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz
	gpg --import ${pwd}/libsodium/libsodium.gpg.pub
	gpg --verify ${pwd}/libsodium/libsodium-1.0.16.tar.gz.sig ./libsodium-1.0.16.tar.gz
	tar -xvf ./libsodium-1.0.16.tar.gz
	rm libsodium-1.0.16.tar.gz
	popd
}

# download/verify/unzip openssl
function setup_openssl() {
	mkdir -p ${TMP}/openssl
	pushd ${TMP}/openssl
	wget https://www.openssl.org/source/openssl-1.0.2o.tar.gz
	gpg --import ${pwd}/openssl/openssl.caswell.gpg.pub
	gpg --import ${pwd}/openssl/openssl.levitte.gpg.pub
	gpg --verify ${pwd}/openssl/openssl-1.0.2o.tar.gz.sig ./openssl-1.0.2o.tar.gz
	tar -xvf openssl-1.0.2o.tar.gz
	rm openssl-1.0.2o.tar.gz
	popd
}

# download the turtl core
function setup_core() {
	source ~/.cargo/env

	mkdir -p ${TMP}/turtl
	pushd ${TMP}/turtl
	git clone https://github.com/turtl/core-rs core
	popd
}

# compiles libsodium statically using our GCC toolchain
function build_libsodium() {
	arch="$1"
	pushd ${TMP}/libsodium/libsodium-1.0.16

	make distclean || make clean || echo "Cannot clean"
	if [ "${arch}" == "armv7" ]; then
		TARGET=arm-linux-androideabi
		export CC="${TARGET}-gcc"
		export PATH="$PATH:${PREFIX_GCC_ARMV7}/bin"
		export TARGET_ARCH=armv7-a
		export CFLAGS="-Os -fPIC -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -marm -march=${TARGET_ARCH}"

		./configure \
			--prefix=${TMP}/libsodium/${TARGET} \
			--with-sysroot=${TMP}/libsodium/${TARGET}/sysroot \
			--host=arm-linux-androideabi \
			--disable-soname-versions \
			--enable-static \
			--disable-shared
	elif [ "${arch}" == "arm64" ]; then
		TARGET=aarch64-linux-android
		export CFLAGS="-fPIC -O2"
		export CC="${TARGET}-gcc"
		export PATH="$PATH:${PREFIX_GCC_ARM64}/bin"

		./configure \
			--prefix=${TMP}/libsodium/${TARGET} \
			--with-sysroot=${TMP}/libsodium/${TARGET}/sysroot \
			--host=aarch64-linux-android \
			--disable-soname-versions \
			--enable-static \
			--disable-shared
	else
		echo "Libsodium: Bad architecture: ${arch}"
		exit 1
	fi

	make
	make install
	popd
}

# compiles openssl statically using our GCC toolchain
function build_openssl() {
	arch="$1"
	pushd ${TMP}/openssl/openssl-1.0.2o

	make distclean || make clean || echo "Cannot clean"
	if [ "${arch}" == "armv7" ]; then
		TARGET=android
		BUILD=armv7-linux-android

		export ANDROID_DEV="${PREFIX_GCC_ARMV7}"
		export PATH="$PATH:${PREFIX_GCC_ARMV7}/bin"

		./Configure \
			${TARGET} \
			no-shared \
			no-ssl2 \
			no-ssl3 \
			no-engine \
			no-dso \
			no-asm \
			no-hw \
			no-comp \
			-D__ANDROID_API__=21 \
			-funroll-loops -ffast-math -O3 \
			-fPIC \
			-DOPENSSL_PIC \
			--cross-compile-prefix="${PREFIX_GCC_ARMV7}/bin/arm-linux-androideabi-" \
			--prefix=${TMP}/openssl/${BUILD}
	elif [ "${arch}" == "arm64" ]; then
		TARGET=linux-aarch64
		BUILD=aarch64-linux-android

		export ANDROID_DEV="${PREFIX_GCC_ARM64}"
		export PATH="$PATH:${PREFIX_GCC_ARM64}/bin"

		./Configure \
			${TARGET} \
			no-shared \
			no-ssl2 \
			no-ssl3 \
			no-engine \
			no-dso \
			no-asm \
			no-hw \
			no-comp \
			-D__ANDROID_API__=21 \
			-funroll-loops -ffast-math -O3 \
			-fPIC \
			-DOPENSSL_PIC \
			--cross-compile-prefix="${PREFIX_GCC_ARM64}/bin/aarch64-linux-android-" \
			--prefix=${TMP}/openssl/${BUILD}
	else
		echo "OpenSSL: Bad architecture: ${arch}"
		exit 1
	fi

	make depend
	make
	make install
	popd
}

# compiles the turtl core
function build_core() {
	arch="$1"
	pushd ${TMP}/turtl/core
	source ~/.cargo/env

	if [ "${arch}" == "armv7" ]; then
		PATH=$PATH:${PREFIX_GCC_ARMV7}/bin make \
			SODIUM_LIB_DIR=${TMP}/libsodium/arm-linux-androideabi/lib \
			SODIUM_STATIC=static \
			OPENSSL_LIB_DIR=${TMP}/openssl/armv7-linux-android/lib \
			OPENSSL_INCLUDE_DIR=${TMP}/openssl/armv7-linux-android/include \
			OPENSSL_STATIC=static\
			CARGO_BUILD_ARGS="${CARGO_BUILD_ARGS} --target armv7-linux-androideabi" \
			FEATURES="build-jni sqlite-static" \
			release
	elif [ "${arch}" == "arm64" ]; then
		PATH=$PATH:${PREFIX_GCC_ARM64}/bin make \
			SODIUM_LIB_DIR=${TMP}/libsodium/aarch64-linux-android/lib \
			SODIUM_STATIC=static \
			OPENSSL_LIB_DIR=${TMP}/openssl/aarch64-linux-android/lib \
			OPENSSL_INCLUDE_DIR=${TMP}/openssl/aarch64-linux-android/include \
			OPENSSL_STATIC=static\
			CARGO_BUILD_ARGS="${CARGO_BUILD_ARGS} --target aarch64-linux-android" \
			FEATURES="build-jni sqlite-static" \
			release
	else
		echo "core: Bad architecture: ${arch}"
		exit 1
	fi
	popd
}

# build the actual android app
function build_android() {
	TARGET_ARMV7=${TMP}/turtl/core/target/armv7-linux-androideabi/release/libturtl_core.so
	TARGET_ARM64=${TMP}/turtl/core/target/aarch64-linux-android/release/libturtl_core.so
	mkdir -p ${TMP}/turtl
	pushd ${TMP}/turtl
	git clone https://github.com/turtl/fdroid
	cd fdroid/app
	mkdir -p libs/armeabi-v7a
	mkdir -p libs/arm64-v8a
	cp ${TARGET_ARMV7} libs/armeabi-v7a
	cp ${TARGET_ARM64} libs/arm64-v8a

	# do normal android build stuff here =]
	# do normal android build stuff here =]
	# do normal android build stuff here =]

	popd
}

# ------------------------------------------------------------------------------
# our main()
# ------------------------------------------------------------------------------
script=$0
cmd=$1
# note that we set this up so each of our functions runs as a call back into the
# build script. the reason for this is they often export ENV vars that conflict
# with other functions, and this makes sure each one runs as a clean slate
case "$cmd" in
	setup_*|build_*)
		shift
		echo "Running ${cmd} $@"
		$cmd "$@"
		;;
	'')
		# init the build system
		$script setup_deps
		$script setup_toolchain
		$script setup_rust
		$script setup_libsodium
		$script setup_openssl
		$script setup_core

		# build core armv7
		$script build_libsodium armv7
		$script build_openssl armv7
		$script build_core armv7

		# build core arm64
		$script build_libsodium arm64
		$script build_openssl arm64
		$script build_core arm64

		# build the final android app
		$script build_android
		;;
	*)
		echo "Unknown command: ${cmd}"
		exit 1
		;;
esac

