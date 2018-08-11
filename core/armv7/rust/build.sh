#!/bin/bash

set -e

cd /builder/rust
./rustup.sh -y --default-toolchain none
source ~/.cargo/env
cat cargo-config >> ~/.cargo/config
rustup toolchain add 1.28.0
rustup default 1.28.0
rustup target add armv7-linux-androideabi

