#!/usr/bin/env bash

case $1 in
    start)
        mkdir -p /web_server/fifos/proc/
        mkfifo /web_server/fifos/proc/request
        echo "Starting process manager daemon..."
        /web_server/daemons/process_manager.sh /web_server/fifos/proc/ &
        echo "Process manager daemon running [$!]"
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$' >> /web_server/fifos/proc/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/proc/request
        echo "Process manager daemon gracefully shut down."
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac