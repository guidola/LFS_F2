#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/proc/request && ! -z `ps -aux | grep /web_server/daemons/process_manager.sh` ]] || (echo "Proc Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "process manager daemon: starting daemon";
        mkdir -p /web_server/fifos/proc/
        mkfifo /web_server/fifos/proc/request
        chown apache:apache -R /web_server/fifos/proc
        echo "Starting process manager daemon..."
        /web_server/daemons/process_manager.sh /web_server/fifos/proc/ >> /var/log/daemons_errors/proc.log 2 >> /var/log/daemons_errors/proc.log &
        echo "Process manager daemon running [$!]"
        logger -p local1.notice "process manager daemon: running";
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$' >> /web_server/fifos/proc/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/proc/*
        echo "Process manager daemon gracefully shut down."
        logger -p local1.notice "process manager daemon: stopped";
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac