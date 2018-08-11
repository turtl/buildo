FROM i386/debian:9.4-slim
RUN apt-get update && \
	apt-get install -y \
		bash \
		build-essential \
		curl \
		git \
		gnupg2 \
		wget
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash && \
	apt-get install -y nodejs
WORKDIR /builder
ADD desktop desktop
# this caches a lot of the core junk
RUN linux32 ./desktop/build.sh
ENV OUTFILE=libturtl_core.so
CMD linux32 ./desktop/build.sh "/builder/out/${OUTFILE}"

