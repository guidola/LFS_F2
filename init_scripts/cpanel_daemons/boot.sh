#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/boot/request && ! -z `ps -aux | grep /web_server/daemons/boot_manager.sh` ]] || (echo "Boot Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "boot manager daemon: starting daemon";
        mkdir -p /web_server/fifos/boot/
        mkfifo /web_server/fifos/boot/request
        chown apache:apache -R /web_server/fifos/boot
        echo "Starting boot manager daemon..."
        /web_server/daemons/boot_manager.sh /web_server/fifos/boot/ < /dev/null 1>>/var/log/daemons_errors/boot.log 2>>/var/log/daemons_errors/boot.log &
        echo "Boot manager daemon running [$!]"
        logger -p local1.notice "boot manager daemon: running"
        ;;
    stop)
        echo "Signaling daemon..."
        (sleep 1; pkill -f "bash /web_server/daemons/boot_manager.sh" 2>>/dev/null) &
        echo '2$$' >> /web_server/fifos/boot/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/boot/*
        echo "Boot manager daemon gracefully shut down."
        logger -p local1.notice "boot manager daemon: stopped"
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac