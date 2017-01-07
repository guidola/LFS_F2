#!/usr/bin/env bash

OIFS="$IFS"
devices=`ls -1 /media/usb/`
echo "Content-Type: application/json"
echo ""
missatge="{\"devices\": ["
IFS=$'\n'
for line in $devices
do
    name=`ls -alt /dev/disk/by-label/ | grep ${line} | awk '{print $9}'`
    name=`echo -e "${name}"`
    missatge="${missatge}{\"path\":\"/media/usb/${line}\",\"name\":\"${name}\"},"
done
IFS=$OIFS
if [[ ${logs:${#logs}-1:1} == "[" ]]; then
    missatge="${missatge}]}"
else
    missatge="${missatge%?}]}"
fi
logger -p local0.notice "CGI show devices: request completed"

