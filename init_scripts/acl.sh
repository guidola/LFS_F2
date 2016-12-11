#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/proc/request && ! -z `ps -aux | grep /web_server/daemons/iptables.sh` ]] || (echo "Daemon already started. Please stop it and start it again" && exit 1)
        mkdir -p /web_server/fifos/acl/
        mkfifo /web_server/fifos/acl/request
        chown www-data:www-data -R /web_server/fifos/acl
        echo "Starting ip tables daemon..."
        touch /web_server/daemons/iptables_daemon_log
        chmod 777 /web_server/daemons/iptables_daemon_log
        /web_server/daemons/iptables.sh /web_server/fifos/acl/ >> /web_server/daemons/iptables_daemon_log 2>> /web_server/daemons/iptables_daemon_log &
        #/web_server/daemons/iptables.sh /web_server/fifos/acl/ &
        echo "IP tables daemon running [$!]"
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$$$$$$$$$$$$' >> /web_server/fifos/acl/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/proc/*
        echo "IP tables daemon gracefully shut down."
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac