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
#设为true，则需用户名、密码才能登录Dashboard,默认的用户名和密码为admin/orange_admin   
if [[ "X${DASHBOARD_AUTH}" != "X" ]]; then
    sed -i "s/\"auth\": false/\"auth\": ${DASHBOARD_AUTH}/g" ${ORANGE_CONF}
fi
if [[ "X${SESSION_SECRET}" != "X" ]]; then
    sed -i "s/\"session_secret\": \"y0ji4pdj61aaf3f11c2e65cd2263d3e7e5\"/\"session_secret\": \"${SESSION_SECRET}\"/g" ${ORANGE_CONF}
fi
if [[ "X${API_USERNAME}" != "X" ]]; then
    sed -i "s/\"username\": \"api_username\"/\"username\": \"${API_USERNAME}\"/g" ${ORANGE_CONF}
fi
if [[ "X${API_PASSWORD}" != "X" ]]; then
    sed -i "s/\"password\": \"api_password\"/\"password\": \"${API_PASSWORD}\"/g" ${ORANGE_CONF}
fi

# Waiting for a mysql fully started
netConnection() {
    while true
    do
        TELNET_1=`echo "quit" | telnet $1 $2 | grep "Escape character is"`
        if [ "$?" -ne 0 ]; then
            echo "Reconnect after 5 seconds"
            sleep 5
        else
            echo "Connected"
            break;
        fi
    done
}

waitForDatabase() {
    echo "Check database connection"
    netConnection ${ORANGE_HOST} ${ORANGE_PORT}
    echo "Database connected"
}

waitForDatabase

# Nginx conf modify
grep "www www" ${NGINX_CONF} > /dev/null
if [ $? -ne 0 ];then
    sed -i "s/worker_processes  4;/user www www;\nworker_processes  4;\ndaemon  off;/g" ${NGINX_CONF}
    # Auto Init database for the first time
    ORANGE_DATABASE_IP=`getent hosts ${ORANGE_HOST} | awk '{ print $1 }'`
    if [[ "X${ORANGE_DB_INIT}" != "X" ]]; then
      orange store -t=mysql -d=${ORANGE_DATABASE} -hh=${ORANGE_DATABASE_IP} -pp=${ORANGE_PORT} -p=${ORANGE_PWD} -u=${ORANGE_USER} -o=init -f=/usr/local/orange/install/orange-v${ORANGE_VERSION}.sql
    fi 
fi
# for k8s
RESOLVER=`cat /etc/resolv.conf | grep nameserver  |  grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
sed -i "s/resolver 114.114.114.114;/resolver ${RESOLVER};/g" ${NGINX_CONF}
sed -i "s/lua_package_path '..\/?.lua;\/usr\/local\/lor\/?.lua;;';/lua_package_path '\/usr\/local\/orange\/?.lua;\/usr\/local\/lor\/?.lua;;';/g" ${NGINX_CONF}
#sed -i "s/listen       80;/listen       8888;/g" ${NGINX_CONF}

/usr/local/bin/orange start

# log to docker
#touch /usr/local/orange/logs/access.log
tail -f /usr/local/orange/logs/access.log /usr/local/orange/logs/error.log
