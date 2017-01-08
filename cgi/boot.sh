#!/usr/bin/env bash

die() {
    logger -p local0.notice CGI boot: bad request
    echo "Status: $1"
    echo""
    exit 0
}

urldecode(){
  read a
  echo -e "`echo ${a} | sed 's/+/ /g;s/%\(..\)/\\\x\1/g;'`"
}


[[ $REQUEST_METHOD -eq "POST" ]] || die "400 Bad Request"

#IFS="$"
shutdown=0
restart=1

[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
ACTION=`echo ${url} | grep -oP '(?<=codi=).*?(?=&)' | urldecode`
#create return fifo
ret_fifo="/web_server/fifos/boot/$$"
mkfifo $ret_fifo
#echo "FIFO ${ret_fifo} created"

#send process request to process manager daemon
echo "Content-Type: application/json"
echo "Status: 200 OK"
echo "1\$$$\$$ACTION" >> /web_server/fifos/boot/request
#echo "Echo to request fifo done --> 1\$$$\$$ACTION"
#wait for response from the boot daemon
read resp_code < $ret_fifo
#echo "Read from return fifo done --> .${resp_code}."

case $ACTION in
    ${shutdown})
        logger -p local0.notice "CGI boot: power off requested"
        ;;
    ${restart})
        logger -p local0.notice "CGI boot: reboot requested"
        ;;
    *)
        die "400 Bad Request"
        ;;

esac

if [[ ! -z $resp_code ]]; then
    case $resp_code in
        ${esyntax})
            #echo "Status: 500 Internal Server Error"
            #echo ""
            #echo "\"Oops. Syntax error\""
            logger -p local0.notice "CGI boot: internal error (syntax error)"
            ;;
        ${ecode})
            #echo "Status: 500 Internal Server Error"
            #echo ""
            #echo "\"Oops. The requested action does not exist\""
            logger -p local0.notice "CGI boot: internal error (wrong action)"
            ;;
        ${xerror})
            #echo "Status: 200 OK"
            #echo ""
            #echo '{"rc": false}'
            logger -p local0.notice "CGI boot: error, the action could not be completed"
            ;;
        ${xcorrect})
            #echo "Status: 200 OK"
            #echo ""
            #echo '{"rc": true}'
            logger -p local0.notice "CGI boot: request success"
            ;;
    esac
fi


