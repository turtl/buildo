#!/bin/bash

TARGET=target/release/libturtl_core.so

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
make release

if [ "${OUTFILE}" != "" ]; then
	echo "- Copy ${TARGET} -> ${OUTFILE}"
	cp "${TARGET}" "${OUTFILE}"
fi

