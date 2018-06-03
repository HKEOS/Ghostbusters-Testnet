#!/bin/bash

PATRONEOSROOT=/opt/patroneos
PIDFILE=/var/run/patroneosd.pid


if [ -f $PIDFILE ]; then
   echo "PID file $FILE exists, restarting"
   kill -SIGTERM `cat $PIDFILE`
fi


# Check if it has been configured
if [ ! -f $PATRONEOSROOT/config.json ]; then
    echo "NOT Configured"
    echo "Enter the target protocol [http]"
    read protocol
    if [[ $protocol == "" ]]; then
        protocol="http"
    fi
    echo "Enter the target IP address [127.0.0.1]"
    read host
    if [[ $host == "" ]]; then
        host="127.0.0.1"
    fi
    echo "Enter the target port [8888]"
    read port
    if [[ $port == "" ]]; then
        port="8888"
    fi

    echo "Enter the listen port [8889]"
    read listen_port
    if [[ $listen_port == "" ]]; then
        listen_port="8889"
    fi

    echo "Configuring 0.0.0.0:$listen_port -> $protocol://$host:$port"
    sed -e "s/\${target_protocol}/${protocol}/" \
        -e "s/\${target_host}/${host}/" \
        -e "s/\${listen_port}/${listen_port}/" \
            $PATRONEOSROOT/config.json.in > $PATRONEOSROOT/config.json
fi


nohup $PATRONEOSROOT/patroneosd -configFile $PATRONEOSROOT/config.json > /var/log/patroneosd.log 2>&1 &
echo $! > $PIDFILE

echo "Started patroneosd and redirecting output to /var/log/patroneosd.log"
