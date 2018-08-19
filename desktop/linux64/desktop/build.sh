#!/bin/bash

TARGET=target/final/turtl-linux64.tar.bz2

# ------------------------------------------------------------------------------

OUTFILE=$1

set -e

mkdir -p /turtl
cd /turtl
if [ ! -d core ]; then
	git clone https://github.com/turtl/core-rs core
fi
if [ ! -d js ]; then
	git clone https://github.com/turtl/js
fi
if [ ! -d desktop ]; then
	git clone https://github.com/turtl/desktop
fi
cd core
git pull
mkdir -p target/release/
cd ../js
git pull
npm install
cp config/config.js.default config/config.js
cd ../desktop
git pull
npm install
make electron-rebuild

if [ "${OUTFILE}" != "" ]; then
	mkdir -p /turtl/desktop/build/
	cp /builder/out/libturtl_core.linux64.so /turtl/desktop/build/turtl_core.so
	make release-linux

	echo "- Copy ${TARGET} -> ${OUTFILE}"
	cp "${TARGET}" "${OUTFILE}"
fi

