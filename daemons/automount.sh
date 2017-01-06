#!/usr/bin/env bash

while true
do
    usbs=`ls /dev/ | grep -e "sd[b-z]"`
    for usb in usbs
    do
        ismounted=`df | grep /dev/${usb}`
        if [[ -z ${ismounted} ]]; then
            devtype=`/sbin/blkid -p /dev/${usb} | sed 's/.*[[:blank:]]TYPE="\([^"]*\)".*/\1/g; s/[[:blank:]]*//g;'`
            mkdir /media/usb/${usb}
            mount -t ${devtype} /dev/${usb} /media/usb/${usb}
            ls -1 /media/${usb}/music/ > /web_server/music/${usb}/originallist.txt
            cat /web_server/music/originallist.txt > /web_server/music/${usb}/playlist.txt
        fi
    done
    sleep 10
done