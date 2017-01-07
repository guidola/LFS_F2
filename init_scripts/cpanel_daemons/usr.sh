#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/usr/request && ! -z `ps -aux | grep /web_server/daemons/user_manager.sh` ]] || (echo "User Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "user manager daemon: starting daemon";
        mkdir -p /web_server/fifos/usr/
        mkfifo /web_server/fifos/usr/request
        chown apache:apache -R /web_server/fifos/usr
        echo "Starting user manager daemon..."
        /web_server/daemons/user_manager.sh /web_server/fifos/usr/ < /dev/null 1>>/var/log/daemons_errors/usr.log 2>>/var/log/daemons_errors/usr.log &
        echo "User manager daemon running [$!]"
        logger -p local1.notice "user manager daemon: running"
        ;;
    stop)
        echo "Signaling daemon..."
        (sleep 1; pkill -f "bash /web_server/daemons/user_manager.sh" 2>>/dev/null) &
        echo '2$$$$$$$$$' >> /web_server/fifos/usr/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/usr/*
        echo "User manager daemon gracefully shut down."
        logger -p local1.notice "user manager daemon: stopped"
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac