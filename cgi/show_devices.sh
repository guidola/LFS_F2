#!/usr/bin/env bash

OIFS="$IFS"
devices=`ls -1 /media/usb/ | grep -P 'sd.[0-9]+'`
echo "Content-Type: application/json"
echo ""
missatge="{\"devices\": ["
IFS=$'\n'
for line in $devices
do

    name=`udevadm info --query=all /dev/$line | grep 'ID_MODEL_ENC' | awk -F= '{print $2}'`
    name=`echo -e "${name}"`
    missatge="${missatge}{\"path\":\"${line}\",\"name\":\"${name}\"},"
done
IFS=$OIFS
if [[ ${missatge:${#missatge}-1:1} == "[" ]]; then
    missatge="${missatge}]}"
else
    missatge="${missatge%?}]}"
fi
echo "$missatge"
logger -p local0.notice "CGI show devices: request completed"

