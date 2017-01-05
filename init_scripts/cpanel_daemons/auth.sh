#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/auth/request && ! -z `ps -aux | grep /web_server/daemons/chkuser.sh` ]] || (echo "Auth Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "check user daemon: starting daemon";
        mkdir -p /web_server/fifos/auth/
        mkfifo /web_server/fifos/auth/request
        chown apache:apache -R /web_server/fifos/auth
        echo "Starting authentication daemon..."
        /web_server/daemons/chkuser.sh /web_server/fifos/auth/ < /dev/null >> /var/log/daemons_errors/auth.log 2 >> /var/log/daemons_errors/auth.log &
        echo "Authentication daemon running [$!]"
        logger -p local1.notice "check user daemon: running";
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$' >> /web_server/fifos/auth/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/auth/*
        echo "Authentication daemon gracefully shut down."
        logger -p local1.notice "check user daemon: stopped";
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac