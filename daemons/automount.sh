#!/usr/bin/env bash

function searchMPFiles {

    for file in $1/*; do
        
        if [[ $file == "${1}/" || $file == "${1}/" || "$file" == "${1}/" ]]; then continue; fi

        #if its a .mp2 or .mp3 file write it to the playlist
        if [[ -f ${file} ]]; then
            if [[ $file =~ \.mp[23]$ ]]; then
                echo ${file} >> $2
            fi;
        fi

        #if its a folder call this func again
        if [[ -d ${file} ]]; then
            searchMPFiles ${file}
        fi

    done;
}


# init mounted devices array
declare -A mounted_devices

while true
do
    usbs=`ls /dev/ | grep -e "sd[b-z]"`
    for usb in $usbs
    do
        echo "found new device"
        ismounted=`df | grep /dev/${usb}`
        if [[ -z ${ismounted} ]]; then
            echo "mounting new device..."
            devtype=`/sbin/blkid -p /dev/${usb} | sed 's/.*[[:blank:]]TYPE="\([^"]*\)".*/\1/g; s/[[:blank:]]*//g;'`
            mkdir -p /media/usb/${usb}
            mkdir -p /web_server/music/${usb}
            mount -t ${devtype} /dev/${usb} /media/usb/${usb}
            [[ $? -eq 0 ]] && mounted_devices["${usb}"]="/media/usb/${usb}"
            # if there are old playlists delete em
            rm -f /web_server/music/${usb}/originallist.txt /web_server/music/${usb}/playlist.txt
            # traverse the drive looking for files with extension .mp2 o .mp3 ( all supported by mpg123 )
            searchMPFiles /media/usb/${usb} /web_server/music/${usb}/originallist.txt
            # touch the originallist to ensure it exists
            touch /web_server/music/${usb}/originallist.txt
            # copy it to the playlist
            cp -f /web_server/music/${usb}/originallist.txt /web_server/music/${usb}/playlist.txt
        fi

        # watch the mounted usbs to umount on disconnection
        for device in ${!mounted_devices[@]}; do
            echo "checking ${device} mounted at ${mounted_devices[${device}]}"
            if [[ -z `ls /dev/ | grep "${device}"` && ! -z `df | grep "${mounted_devices[${device}]}"` ]]; then
                echo "${device} disconnected"
                umount ${mounted_devices[${device}]}
                echo "unmounted ${device} mounted at ${mounted_devices[${device}] with code $?}"
            fi
        done

    done
    sleep 1
done