#!/bin/bash

set -e 

mkdir -p /tmp/android-sdk
cd /tmp/android-sdk
wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
unzip sdk-tools-linux-4333796.zip
cd tools
echo 'y' | ./bin/sdkmanager 'platforms;android-26' 'ndk-bundle'
cd ../ndk-bundle
./build/tools/make_standalone_toolchain.py --arch arm --api 26 --install-dir /opt/gcc-armv7-android
cd
rm -rf /tmp/android-sdk

