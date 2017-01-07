#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -p /web_server/fifos/music/request && ! -z `ps -aux | grep /web_server/daemons/music_player.sh` ]] || (echo "Music player Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "music player daemon: starting daemon";
        mkdir -p /web_server/fifos/music/
        mkfifo /web_server/fifos/music/request
        mkfifo /web_server/fifos/music/mpg123_fifo
        mpg123 -R --fifo web_server/fifos/music/mpg123_fifo >> /dev/null &
        echo "SILENCE" > web_server/fifos/music/mpg123_fifo
        chown apache:apache -R /web_server/fifos/music
        echo "Starting music player daemon..."
        /web_server/daemons/music_player.sh /web_server/fifos/music/ < /dev/null 1>>/var/log/daemons_errors/music.log 2>>/var/log/daemons_errors/music.log &
        echo "Music player daemon running [$!]"
        logger -p local1.notice "music player daemon: running"
        ;;
    stop)
        echo "Signaling daemon..."
        (sleep 1; pkill -f "bash /web_server/daemons/music_player.sh" 2>>/dev/null) &
        echo '2$$$' >> /web_server/fifos/music/request
        echo "Waiting for on-going requests to end..."
        rm -f /web_server/fifos/music/*
        echo "Music player daemon gracefully shut down."
        logger -p local1.notice "music player daemon: stopped"
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac