#!/usr/bin/env bash

case $1 in
    start)
        [[ ! -z `ps -aux | grep /web_server/daemons/music_player.sh` ]] || (echo "Automount Daemon already started. Please stop it and start it again" && exit 1)
        logger -p local1.notice "automount daemon: starting daemon";
        mkdir -p /media/usb
        echo "Starting automount daemon..."
        /web_server/daemons/automount.sh < /dev/null >> /var/log/daemons_errors/automount.log 2 >> /var/log/daemons_errors/automount.log &
        echo "Automount daemon running [$!]"
        logger -p local1.notice "automount daemon: running";
        ;;
    stop)
        PID=`ps aux | grep /web_server/daemons/automount.sh | awk 'NR==1 {print $2}'`
        kill ${PID}
        devices=`ls -1 /media/usb/`
        IFS=$'\n'
        for usb in $devices
        do
            umount /dev/${usb}
        done
        rm -rf /media/usb
        echo "Automount daemon gracefully shut down."
        logger -p local1.notice "automount daemon: stopped";
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac