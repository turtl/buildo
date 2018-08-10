#!/bin/bash

set -e

mkdir -p /tmp/openssl
cd /tmp/openssl
wget https://www.openssl.org/source/openssl-1.0.2o.tar.gz
gpg --import /builder/openssl/openssl.caswell.gpg.pub
gpg --import /builder/openssl/openssl.levitte.gpg.pub
gpg --verify /builder/openssl/openssl-1.0.2o.tar.gz.sig ./openssl-1.0.2o.tar.gz
tar -xvf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o
#export C_INCLUDE_PATH=/usr/include/$(gcc -print-multiarch)
./Configure \
        linux-generic32 \
		-m32 \
        no-shared \
        no-ssl2 \
        no-ssl3 \
        no-engine \
        no-dso \
        no-asm \
        no-hw \
        no-comp \
        -funroll-loops -ffast-math -O3 \
        -fPIC \
        -DOPENSSL_PIC \
        --prefix=/opt/openssl
make depend
make
make install

