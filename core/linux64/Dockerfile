FROM debian:7.11-slim
RUN apt-get update && \
	apt-get install -y \
		bash \
		build-essential \
		curl \
		git \
		gnupg2 \
		wget
WORKDIR /builder
ADD libsodium libsodium
RUN ./libsodium/build.sh
ADD openssl openssl
RUN ./openssl/build.sh
ADD rustup.sh .
RUN chmod 755 rustup.sh && \
	./rustup.sh -y --default-toolchain 1.31.0
ADD core core
# this caches a lot of the core junk
RUN ./core/build.sh
ENV OUTFILE=libturtl_core.so
CMD ./core/build.sh "/builder/out/${OUTFILE}"

