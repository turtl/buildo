#!/bin/bash

set -e 

mkdir -p /tmp/android-sdk
cd /tmp/android-sdk
wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
unzip sdk-tools-linux-4333796.zip
cd tools
echo 'y' | ./bin/sdkmanager 'platforms;android-23'
# note that we can't use the latest NDK because it doesn't include GCC,
# and we need a GCC toolchain to compile openssl
wget https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip
unzip android-ndk-r17c-linux-x86_64.zip
mv android-ndk-r17c ndk-bundle
cd ndk-bundle
./build/tools/make_standalone_toolchain.py --arch arm64 --api 23 --install-dir /opt/gcc-arm64-android
cd
rm -rf /tmp/android-sdk

