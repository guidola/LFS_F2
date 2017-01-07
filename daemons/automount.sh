#!/usr/bin/env bash

function searchMPFiles {

    for file in $1/*; do
        
        if [[ $file == "${1}/" || $file == "${1}/" || "$file" == "${1}/" ]]; then continue; fi

        #if its a .mp2 or .mp3 file write it to the playlist
        if [[ -f ${file} ]]; then
            if [[ $file =~ \.mp[23]$ ]]; then
                echo ${file:${#1}} >> $2
            fi;
        fi

        #if its a folder call this func again
        if [[ -d ${file} ]]; then
            searchMPFiles ${file}
        fi

    done;
}


while true
do
    usbs=`ls /dev/ | grep -e "sd[b-z]"`
    for usb in usbs
    do
        ismounted=`df | grep /dev/${usb}`
        if [[ -z ${ismounted} ]]; then
            devtype=`/sbin/blkid -p /dev/${usb} | sed 's/.*[[:blank:]]TYPE="\([^"]*\)".*/\1/g; s/[[:blank:]]*//g;'`
            mkdir -p /media/usb/${usb}
            mount -t ${devtype} /dev/${usb} /media/usb/${usb}
            # if there are old playlists delete em
            rm -f /web_server/music/${usb}/originallist.txt /web_server/music/${usb}/playlist.txt
            # traverse the drive looking for files with extension .mp2 o .mp3 ( all supported by mpg123 )
            searchMPFiles /media/usb/${usb} /web_server/music/${usb}/originallist.txt
            # ls -1 /media/${usb}/music/ > /web_server/music/${usb}/originallist.txt # mec, aixo suposa que esta tot en una carpeta i s'ha de buscar tota la musica del pen
            cp -f /web_server/music/${usb}/originallist.txt /web_server/music/${usb}/playlist.txt
        fi
    done
    sleep 1
done