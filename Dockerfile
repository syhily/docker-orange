FROM openresty/openresty:latest-centos
MAINTAINER Syhily, syhily@gmail.com

# Docker Build Arguments, For further upgrade
ENV ORANGE_PATH="/usr/local/orange"
ARG LOR_VERSION="0.3.0"
ARG ORANGE_VERSION="0.6.2"

# 1) Install yum dependencies
# 2) Cleanup
RUN \
    yum install -y \
        libuuid-devel \
        dnsmasq \
    && yum clean all

# 1) Install lor
# 2) Install orange
# 3) Cleanup
# 4) dnsmasq

RUN \
    cd /tmp \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && ln -s /usr/local/openresty/bin/resty /usr/local/bin/resty \

    && curl -fSL https://github.com/sumory/lor/archive/v${LOR_VERSION}.tar.gz -o lor.tar.gz \
    && tar zxf lor.tar.gz \
    && cd /tmp/lor-${LOR_VERSION} \
    && make install \

    && cd /tmp \
    && curl -fSL https://github.com/sumory/orange/archive/${ORANGE_VERSION}.tar.gz -o orange.tar.gz \
    && tar zxf orange.tar.gz \
    && cd orange-${ORANGE_VERSION} \
    && make install \

    && cd / \
    && rm -rf /tmp/* \

    && echo "user=root" > /etc/dnsmasq.conf \
    && echo 'domain-needed' >> /etc/dnsmasq.conf \
    && echo 'listen-address=127.0.0.1' >> /etc/dnsmasq.conf \
    && echo 'resolv-file=/etc/resolv.dnsmasq.conf' >> /etc/dnsmasq.conf \
    && echo 'conf-dir=/etc/dnsmasq.d' >> /etc/dnsmasq.conf \
    # This upstream dns server will cause some issues
    && echo 'INTERNAL_DNS' >> /etc/resolv.dnsmasq.conf \
    && echo 'nameserver 8.8.8.8' >> /etc/resolv.dnsmasq.conf \
    && echo 'nameserver 8.8.4.4' >> /etc/resolv.dnsmasq.conf

# 1) Add User
# 2) Add configuration file & bootstrap file
# 3) Fix file permission

RUN \
    useradd www \
    && echo "www:www" | chpasswd \
    && echo "www   ALL=(ALL)       ALL" >> /etc/sudoers

RUN \
    mkdir -p ${ORANGE_PATH}/logs \
    && chown -R www:www ${ORANGE_PATH}/*

# Show installization info for debug

RUN \
    nginx -V

# Set the default command to execute
# when creating a new container

ADD docker-entrypoint.sh docker-entrypoint.sh
RUN \
    chmod 755 docker-entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin

EXPOSE 7777 8888 9999

# Daemon
ENTRYPOINT ["docker-entrypoint.sh"]
