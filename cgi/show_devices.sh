#!/usr/bin/env bash

OIFS="$IFS"
devices=`ls -1 /media/usb/`
echo "Content-Type: application/json"
echo ""
missatge="{\"devices\": ["
IFS=$'\n'
for line in $devices
do
    missatge="${missatge}{\"path\":\"/media/usb/${line}\",\"name\":\"${line}\"},"
done
IFS=$OIFS
if [[ ${logs:${#logs}-1:1} == "[" ]]; then
    missatge="${missatge}]}"
else
    missatge="${missatge%?}]}"
fi
logger -p local0.notice "CGI show devices: request completed"

