FROM openresty/openresty:latest-centos
MAINTAINER Syhily, syhily@gmail.com


# Docker Build Arguments, For further upgrade

ARG LUAJIT_MIRROR="https://cat.yufan.me/dev/luajit"
# ARG LUAJIT_MIRROR="http://luajit.org/download"
ARG LUAJIT_VERSION="LuaJIT-2.1.0-beta2"
ARG LUAJIT_EXECUTEABLE_FILE_NAME="luajit-2.1.0-beta2"
ENV ORANGE_PATH="/usr/local/orange"
ARG ORANGE_GITHUB_REPO="https://github.com/sumory/orange.git"
ARG LOR_GITHUB_REPO="https://github.com/sumory/lor.git"


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
    && curl -fSL ${LUAJIT_MIRROR}/${LUAJIT_VERSION}.tar.gz -o ${LUAJIT_VERSION}.tar.gz \
    && tar zxf ${LUAJIT_VERSION}.tar.gz \
    && cd /tmp/${LUAJIT_VERSION} \
    && make INSTALL_TNAME=luajit \
    && make install \
    && ln -sf /usr/local/bin/${LUAJIT_EXECUTEABLE_FILE_NAME} /usr/local/bin/luajit \
    && git clone ${LOR_GITHUB_REPO} \
    && rm -rf lor/.git \
    && cd lor \
    && sh install.sh \
    && cd /tmp \
    && git clone ${ORANGE_GITHUB_REPO} \
    && rm -rf orange/.git \
    && mv orange /usr/local \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && rm -rf /tmp/* \
    && yum remove -y git


# 1) Add User
# 2) Add configuration file & bootstrap file
# 3) Fix file permission

RUN \
    useradd www \
    && echo "www:www" | chpasswd \
    && echo "www   ALL=(ALL)       ALL" >> /etc/sudoers

ADD nginx.conf nginx.conf
ADD orange orange
ADD orange.conf orange.conf

RUN \
    mv nginx.conf ${ORANGE_PATH}/conf \
    && mkdir -p ${ORANGE_PATH}/logs \
    && chmod 755 orange \
    && mv orange /usr/local/bin \
    && mv orange.conf ${ORANGE_PATH} \
    && cd ${ORANGE_PATH} \
    && chown -R www:www ./*


# Show installization info

RUN \
    nginx -V \
    && lord version


# Set the default command to execute
# when creating a new container

CMD orange start

EXPOSE 8888 9999
