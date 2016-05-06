FROM debian:jessie
RUN apt-get update && apt-get install -y curl \
        libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make build-essential \
        && rm -rf /var/lib/apt/lists/*

ENV OPENRESTY_VERSION 1.9.7.4
ENV OPENRESTY_PREFIX /opt/openresty
ENV OPENRESTY_CONFIG_PREFIX /etc/nginx
ENV OPENRESTY_VAR_PREFIX /var/run/nginx
RUN rm -rf $OPENRESTY_PREFIX && mkdir $OPENRESTY_PREFIX \
        && rm -rf $OPENRESTY_CONFIG_PREFIX && mkdir $OPENRESTY_CONFIG_PREFIX \
        && rm -rf $OPENRESTY_VAR_PREFIX && mkdir $OPENRESTY_VAR_PREFIX

WORKDIR /tmp/
RUN echo 'start downloading and unzip package' \
        && curl -sSL https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz | tar -xz \
		&& echo 'start configure' \
        && cd /tmp/openresty-${OPENRESTY_VERSION} \
        && ./configure \
                --prefix=$OPENRESTY_PREFIX \
                --conf-path=$OPENRESTY_CONFIG_PREFIX \
                --pid-path=${OPENRESTY_CONFIG_PREFIX}/nginx.pid \
                --lock-path=PATH=${OPENRESTY_CONFIG_PREFIX}/nginx.lock  \
                --with-luajit \
                --with-pcre-jit \
                --with-ipv6 \
                --with-http_ssl_module \
                --without-http_ssi_module \
                --without-http_userid_module \
                --without-http_uwsgi_module \
                --without-http_scgi_module \
        && echo 'start make and install' \
        && make && make install \
        && echo 'clean build tmp' \
        && rm -rf /tmp/openresty*
		
COPY ./conf/* /etc/nginx/

RUN apt-get update && apt-get install -y pandoc git
WORKDIR /tmp/
RUN git clone https://github.com/openresty/openresty.org.git && cd openresty.org/v2 && make initdb
