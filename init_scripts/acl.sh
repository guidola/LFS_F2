#!/usr/bin/env bash

case $1 in
    start)
        mkdir -p /web_server/fifos/acl/
        mkfifo /web_server/fifos/acl/request
        echo "Starting ip tables daemon..."
        /web_server/daemons/process_manager /web_server/fifos/acl/ &
        echo "IP tables daemon running [$!]"
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$$$$$$$$$$$$' >> /web_server/fifos/acl/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/proc/request
        echo "IP tables daemon gracefully shut down."
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac