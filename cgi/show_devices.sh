#!/usr/bin/env bash

OIFS="$IFS"
devices=`ls -1 /media/usb/`
echo "Content-Type: application/json"
echo ""
missatge="{\"devices\": ["
IFS=$'\n'
for line in $devices
do
    missatge="${missatge}\"${line}\","
done
IFS=$OIFS
missatge="${missatge%?}]}"
logger -p local0.notice "CGI show devices: request completed"

