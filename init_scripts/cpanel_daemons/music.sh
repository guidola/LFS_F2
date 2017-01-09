#!/usr/bin/env bash

case $1 in
    start)
        if [[ -p /web_server/fifos/music/request && -z `ps -aux | grep /web_server/daemons/music_player.sh` ]]; then
            echo "Music player Daemon already started. Please stop it and start it again"
            exit 1
        fi
        echo "initializing mpg123..."
        logger -p local1.notice "music player daemon: starting daemon";
        mkdir -p /web_server/fifos/music/
        mkfifo /web_server/fifos/music/request
        mkfifo /web_server/fifos/music/mpg123_fifo
        mpg123 -R --fifo /web_server/fifos/music/mpg123_fifo < /dev/null 1>>/var/log/daemons_errors/mpg123.log 2>>/var/log/daemons_errors/mpg123.log &
        disown
        echo "mpg123 up, silencing..."
        echo "SILENCE" > /web_server/fifos/music/mpg123_fifo 1>/dev/null 2>/dev/null & #ho tirem al bg pq es queda frozen here
        chown apache:apache -R /web_server/fifos/music
        echo "mpg123 silenced & initialized!"
        echo "Starting music player daemon..."
        /web_server/daemons/music_player.sh /web_server/fifos/music/ < /dev/null 1>>/var/log/daemons_errors/music.log 2>>/var/log/daemons_errors/music.log &
        echo "Music player daemon running [$!]"
        logger -p local1.notice "music player daemon: running"
        exit 0
        ;;
    stop)
        echo "Signaling daemon..."
        (sleep 1; pkill -f "bash /web_server/daemons/music_player.sh" 2>>/dev/null; pkill --signal 9 "mpg123 -R --fifo /web_server/fifos/music/mpg123_fifo") &
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