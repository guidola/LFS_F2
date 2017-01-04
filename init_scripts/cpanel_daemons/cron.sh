#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/cron/request && ! -z `ps -aux | grep /web_server/daemons/cron_manager.sh` ]] || (echo "Daemon already started. Please stop it and start it again" && exit 1)
        mkdir -p /web_server/fifos/cron/
        mkfifo /web_server/fifos/cron/request
        mkdir -p /web_server/tmp/cron/
        chown apache:apache -R /web_server/fifos/cron
        echo "Starting user manager daemon..."
        #touch /web_server/daemons/cron_manager_daemon_log
        #chmod 777 /web_server/daemons/cron_manager_daemon_log
        #/web_server/daemons/cron_manager.sh /web_server/fifos/cron/ >> /web_server/daemons/cron_manager_daemon_log 2>> /web_server/daemons/cron_manager_daemon_log &
        /web_server/daemons/cron_manager.sh /web_server/fifos/cron/ &
        echo "Cron manager daemon running [$!]"
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$$$$$$$$$' >> /web_server/fifos/cron/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/cron/*
        rm -f /web_server/tmp/cron/*
        echo "Cron manager daemon gracefully shut down."
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac