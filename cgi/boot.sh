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
        echo "Status: 500 Internal Server Error"
        echo ""
        echo "\"Oops. Syntax error\""
        ;;
    ${restart})
        echo "Status: 500 Internal Server Error"
        echo ""
        echo "\"Oops. The requested action does not exist\""
        ;;
    *)
        die
        ;;

esac


