#!/bin/bash

set -e

cd /builder/rust
./rustup.sh -y --default-toolchain none
source ~/.cargo/env
cat cargo-config >> ~/.cargo/config
rustup toolchain add 1.31.0
rustup default 1.31.0
rustup target add aarch64-linux-android

