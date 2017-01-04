#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/proc/request && ! -z `ps -aux | grep /web_server/daemons/process_manager.sh` ]] || (echo "Daemon already started. Please stop it and start it again" && exit 1)
        mkdir -p /web_server/fifos/proc/
        mkfifo /web_server/fifos/proc/request
        chown apache:apache -R /web_server/fifos/proc
        echo "Starting process manager daemon..."
        #touch /web_server/daemons/proc_daemon_log
        #chmod 777 /web_server/daemons/proc_daemon_log
        #/web_server/daemons/process_manager.sh /web_server/fifos/proc/ >> /web_server/daemons/proc_daemon_log 2>> /web_server/daemons/proc_daemon_log &
        /web_server/daemons/process_manager.sh /web_server/fifos/proc/ &
        echo "Process manager daemon running [$!]"
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$' >> /web_server/fifos/proc/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/proc/*
        echo "Process manager daemon gracefully shut down."
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac