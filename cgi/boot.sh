#!/usr/bin/env bash

die() {
    echo "Status: $1"
    echo""
    exit 0
}

urldecode(){
  echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x/g;')"
}


[[ $REQUEST_METHOD -eq "POST" ]] || die "400 Bad Request"

#IFS="$"
shutdown=0
restart=1

[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
CODI=`echo ${url} | grep -oP '(?<=codi=).*?(?=&)' | urldecode`

case $resp_code in
    ${shutdown})
        poweroff
        #shutdown -P now
        ;;
    ${restart})
        reboot
        #shutdown -r now
        ;;
    *)
        die
        ;;

esac


