#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/cron/request && ! -z `ps -aux | grep /web_server/daemons/cron_manager.sh` ]] || (echo "Cron Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "cron manager daemon: starting daemon";
        mkdir -p /web_server/fifos/cron/
        mkfifo /web_server/fifos/cron/request
        mkdir -p /web_server/tmp/cron/
        chown apache:apache -R /web_server/fifos/cron
        echo "Starting user manager daemon..."
        /web_server/daemons/cron_manager.sh /web_server/fifos/cron/ < /dev/null 1>>/var/log/daemons_errors/cron.log 2>>/var/log/daemons_errors/cron.log &
        echo "Cron manager daemon running [$!]"
        logger -p local1.notice "cron manager daemon: running"
        ;;
    stop)
        echo "Signaling daemon..."
        (sleep 1; pkill -f "bash /web_server/daemons/cron_manager.sh" 2>>/dev/null) &
        echo '2$$$$$$$$$$$' >> /web_server/fifos/cron/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/cron/*
        rm -f /web_server/tmp/cron/*
        echo "Cron manager daemon gracefully shut down."
        logger -p local1.notice "cron manager daemon: stopped"
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac