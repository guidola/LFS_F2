#!/usr/bin/env bash

die() {
    logger -p local0.notice CGI boot: bad request
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

case $CODI in
    ${shutdown})
        logger -p local0.notice CGI boot: power off requested
        poweroff
        #shutdown -P now
        ;;
    ${restart})
        logger -p local0.notice CGI boot: reboot requested
        reboot
        #shutdown -r now
        ;;
    *)
        die
        ;;

esac


