#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/acl/request && ! -z `ps -aux | grep /web_server/daemons/iptables.sh` ]] || (echo "ACL Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "iptables daemon: starting daemon";
        mkdir -p /web_server/fifos/acl/
        mkfifo /web_server/fifos/acl/request
        chown apache:apache -R /web_server/fifos/acl
        echo "Starting ip tables daemon..."
        /web_server/daemons/iptables.sh /web_server/fifos/acl/ < /dev/null 1>>/var/log/daemons_errors/acl.log 2>>/var/log/daemons_errors/acl.log &
        echo "IP tables daemon running [$!]"
        logger -p local1.notice "iptables daemon: running";
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$$$$$$$$$$$$' >> /web_server/fifos/acl/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/acl/*
        echo "IP tables daemon gracefully shut down."
        logger -p local1.notice "iptables daemon: stopped";
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac