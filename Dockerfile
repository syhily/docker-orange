FROM openresty/openresty:latest-centos
MAINTAINER Syhily, syhily@gmail.com

# Docker Build Arguments
ARG LUAJIT_VERSION="LuaJIT-2.1.0-beta2"

# 1) Install yum dependencies
# 2) Cleanup

RUN \
    yum install -y \
        libuuid-devel \
        git \
    && yum clean all

# 1) Install LuaJIT
# 2) Install lor
# 3) Install orange
# 4) Cleanup

RUN \
    cd /tmp \
    && curl -fSL http://luajit.org/download/${LUAJIT_VERSION}.tar.gz -o ${LUAJIT_VERSION}.tar.gz \
    && tar zxf ${LUAJIT_VERSION}.tar.gz \
    && cd /tmp/${LUAJIT_VERSION} \
    && make INSTALL_TNAME=luajit \
    && make install \
    && ln -sf /usr/local/bin/luajit-2.1.0-beta2 /usr/local/bin/luajit \
    && git clone https://github.com/sumory/lor \
    && cd lor \
    && sh install.sh \
    && cd /tmp \
    && git clone https://github.com/sumory/orange.git \
    && rm -rf orange/.git \
    && mv orange /usr/local \
    && chmod 755 /usr/local/orange/start.sh \
    && ln -sf /usr/local/orange/start.sh /usr/local/bin/orange \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && rm -rf /tmp/*


# Show install info

RUN \
    nginx -V \
    && lord version

# CMD orange

EXPOSE 80 9999 8001 9001
