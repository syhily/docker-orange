#!/bin/bash
ORANGE_CONF="/usr/local/orange/conf/orange.conf"
NGINX_CONF="/usr/local/orange/conf/nginx.conf"

# DNS resolve for nginx and add the internal DNS
INTERNAL_DNS=$(cat /etc/resolv.conf | grep nameserver)
sed -i "s/INTERNAL_DNS/${INTERNAL_DNS}/g" /etc/resolv.dnsmasq.conf
dnsmasq

# if command starts with option, init mysql
if [[ "X${ORANGE_DATABASE}" != "X" ]]; then
    sed -i "s/\"host\": \"127.0.0.1\"/\"host\": \"${ORANGE_HOST}\"/g" ${ORANGE_CONF}
    sed -i "s/\"port\": \"3306\"/\"port\": \"${ORANGE_PORT}\"/g" ${ORANGE_CONF}
    sed -i "s/\"database\": \"orange\"/\"database\": \"${ORANGE_DATABASE}\"/g" ${ORANGE_CONF}
    sed -i "s/\"user\": \"root\"/\"user\": \"${ORANGE_USER}\"/g" ${ORANGE_CONF}
    sed -i "s/\"password\": \"\"/\"password\": \"${ORANGE_PWD}\"/g" ${ORANGE_CONF}
fi

# Nginx conf modify
grep "www www" ${NGINX_CONF} > /dev/null
if [ $? -ne 0 ];then
    sed -i "s/worker_processes  4;/user www www;\nworker_processes  4;\ndaemon  off;/g" ${NGINX_CONF}
fi
sed -i "s/resolver 114.114.114.114;/resolver 127.0.0.1 ipv6=off;/g" ${NGINX_CONF}
sed -i "s/lua_package_path '..\/?.lua;\/usr\/local\/lor\/?.lua;;';/lua_package_path '\/usr\/local\/orange\/?.lua;\/usr\/local\/lor\/?.lua;;';/g" ${NGINX_CONF}
sed -i "s/listen       80;/listen       8888;/g" ${NGINX_CONF}

/usr/local/bin/orange start

# log to docker
tail -f /usr/local/orange/logs/access.log
