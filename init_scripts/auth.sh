#!/usr/bin/env bash

case $1 in
    start)
        mkdir -p /web_server/fifos/auth/
        mkfifo /web_server/fifos/auth/request
        echo "Starting authentication daemon..."
        /web_server/daemons/chkuser.sh /web_server/fifos/auth/ &
        echo "Authentication daemon running [$!]"
        ;;
    stop)
        echo "Signaling daemon..."
        echo '2$$$' >> /web_server/fifos/auth/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/auth/request
        echo "Authentication daemon gracefully shut down."
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac