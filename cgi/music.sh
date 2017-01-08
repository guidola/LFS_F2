#!/usr/bin/env bash

die() {
    logger -p local0.notice "CGI music: bad request"
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
play=0
pause_resume=1
next=2
previous=3
random=4
unrandom=5
repeat=6
unrepeat=7
show=8
stop=9
xcorrect=0
xerror=1
esyntax=2
ecode=3

[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
ACTION=`echo ${url} | grep -oP '(?<=action=).*?(?=&)' | urldecode`
SONG=`echo ${url} | grep -oP '(?<=song=).*?(?=&)' | urldecode`
USB=`echo ${url} | grep -oP '(?<=usb=).*?(?=&)' | urldecode`


#verify we got all params we need.
[[ ! -z  $ACTION ]] || ACTION=${show}
[[ ! -z $USB ]] || die "400 Bad Request"


#create return fifo
ret_fifo="/web_server/fifos/music/$$"
mkfifo $ret_fifo
#echo "FIFO ${ret_fifo} created"

#send process request to process manager daemon
echo "1\$$$\$$ACTION\$$USB\$$SONG" >> /web_server/fifos/music/request
#echo "Echo to request fifo done --> 1\$$$\$$ACTION\$$USB\$$SONG"
#wait for response from the authentication daemon
read resp_code < $ret_fifo
#echo "Read from return fifo done --> .${resp_code}."
echo "Content-Type: application/json"

case $ACTION in
    ${play})
        logger -p local0.notice "CGI music: play song ${SONG} request"
         ;;
    ${pause_resume})
        logger -p local0.notice "CGI music: pause or resume song request"
         ;;
    ${next})
        logger -p local0.notice "CGI music: next song request"
         ;;
    ${previous})
        logger -p local0.notice "CGI music: previous song request"
         ;;
    ${random})
        logger -p local0.notice "CGI music: random list request"
         ;;
    ${unrandom})
        logger -p local0.notice "CGI music: original list request"
         ;;
    ${repeat})
        logger -p local0.notice "CGI music: repeat song request"
         ;;
    ${unrepeat})
        logger -p local0.notice "CGI music: unrepeat song request"
         ;;
    ${show})
        logger -p local0.notice "CGI music: show list request"
         ;;
    ${stop})
        logger -p local0.notice "CGI music: stop song request"
         ;;
esac

if [[ ! -z $resp_code ]]; then
    case $resp_code in
        ${esyntax})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. Syntax error\""
            logger -p local0.notice "CGI music: internal error (syntax error)"
            ;;
        ${ecode})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. The requested action does not exist\""
            logger -p local0.notice "CGI music: internal error (wrong action)"
            ;;
        ${xerror})
            echo "Status: 200 OK"
            echo ""
            echo '{"rc": false}'
            logger -p local0.notice "CGI music: error, the action could not be completed"
            ;;
        ${xcorrect})
            echo "Status: 200 OK"
            echo ""
            echo "Dobao is the JS king" >> "${ret_fifo}"
            read response < $ret_fifo
            #echo "second read done"
            echo "{\"rc\":true, \"payload\": ${response}}"
            #NO s'ha de fer cas del current si s'ha demanat un repeat
            logger -p local0.notice "CGI music: request success"
            ;;
    esac
fi
