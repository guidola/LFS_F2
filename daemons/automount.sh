#!/usr/bin/env bash

mounted=0
while true
do
    usbs=`ls /dev/ | grep -e "sd[b-z]"`
    for usb in usbs
    do
        ismounted=`df | grep /dev/${usb}`
        if [[ -z ${ismounted} ]]; then
            mount
        fi
    done
done