FROM ubuntu
ENV THRIFT_VERSION 0.9.3
ARG DEBIAN_FRONTEND=noninteractive
ARG REPO
ARG THRIFT_ENTRYPOINT
COPY ./$REPO /rpc

# BASIC INSTALLS
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    curl \
    wget \
    vim \
    make

# PYTHON INSTALL
RUN apt-get install build-essential checkinstall -y \
    && apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev -y \
    && cd /usr/src \
    && wget https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz \
    && tar xzf Python-2.7.12.tgz \
    && cd Python-2.7.12 \
    && ./configure --enable-optimizations \
    && make altinstall

# THRIFT INSTALL
RUN buildDeps=" \
		automake \
		bison \
		curl \
		flex \
		g++ \
		libboost-dev \
		libboost-filesystem-dev \
		libboost-program-options-dev \
		libboost-system-dev \
		libboost-test-dev \
		libevent-dev \
		libssl-dev \
		libtool \
		make \
		pkg-config \
	"; \
	apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
	&& curl -sSL "http://apache.mirrors.spacedump.net/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz" -o thrift.tar.gz \
	&& mkdir -p /usr/src/thrift \
	&& tar zxf thrift.tar.gz -C /usr/src/thrift --strip-components=1 \
	&& rm thrift.tar.gz \
	&& cd /usr/src/thrift \
	&& ./configure  --without-python --without-cpp \
	&& make \
	&& make install \
	&& cd / \
	&& rm -rf /usr/src/thrift \
	&& curl -k -sSL "https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz" -o go.tar.gz \
	&& tar xzf go.tar.gz \
	&& rm go.tar.gz \
	&& cp go/bin/gofmt /usr/bin/gofmt \
	&& rm -rf go \
	&& apt-get purge -y --auto-remove $buildDeps

#ENTRYPOINT ["/bin/echo", "Hello"]
WORKDIR /rpc
CMD [ "thrift", "-version" ]
CMD [ "/usr/local/bin/python2.7", $THRIFT_ENTRYPOINT ]
EXPOSE 1337
