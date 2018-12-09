FROM debian:9.4-slim
RUN mkdir -p /usr/share/man/man1 && \
	apt-get update && \
	apt-get install -y \
		bash \
		build-essential \
		curl \
		default-jre \
		git \
		gnupg2 \
		python \
		unzip \
		wget
WORKDIR /builder
ADD toolchain toolchain
RUN ./toolchain/build.sh
ADD libsodium libsodium
RUN ./libsodium/build.sh
ADD openssl openssl
RUN ./openssl/build.sh
ADD rust rust
RUN ./rust/build.sh
ADD core core
# this caches a lot of the core junk
RUN ./core/build.sh
ENV OUTFILE=libturtl_core.so
ENV DEBUG=""
CMD ./core/build.sh "/builder/out/${OUTFILE}"

