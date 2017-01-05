#!/usr/bin/env bash

die() {
    logger -p local0.notice "CGI manage processes: bad request"
    echo "Status: $1"
    echo""
    exit 0
}


[[ $REQUEST_METHOD -eq "POST" ]] || die "400 Bad Request"

IFS="$"
xcorrect="0"
xwrong="1"
esyntax="2"
wpid="3"
ecode="4"
kill=0
pause=1

read -n $CONTENT_LENGTH url
url="${url}&"
ACTION=`echo ${url} | grep -oP '(?<=action=).*?(?=&)'`
PID=`echo ${url} | grep -oP '(?<=pid=).*?(?=&)'`
TIME=`echo ${url} | grep -oP '(?<=time=).*?(?=&)'`
#verify we got all params we need.
[[ ! -z  $ACTION && ! -z $PID && ($ACTION -ne 1 || ! -z $TIME) ]] || die "Status: 400 Bad Request"
[[ $ACTION -ne 2 ]] || die "400 Bad Request"

#create return fifo
ret_fifo="/web_server/fifos/proc/$$"
mkfifo $ret_fifo
#echo "FIFO ${ret_fifo} created"

#send process request to process manager daemon
echo "${ACTION}\$${PID}\$${TIME}\$$$" >> /web_server/fifos/proc/request
#echo "Echo to request fifo done --> ${ACTION}\$${PID}\$${TIME}\$$$"

#wait for response from the authentication daemon
read resp_code < $ret_fifo
#echo "Read from return fifo done --> .${resp_code}."
echo "Content-Type: application/json"

if [[ $ACTION -eq $kill ]]; then
    logger -p local0.notice "CGI manage processess: kill process with PID ${PID} request"
elif [[ $ACTION -eq $pause ]]; then
    logger -p local0.notice "CGI manage processess: pause process with PID ${PID} for ${TIME} seconds request"
else
    logger -p local0.notice "CGI manage processess: unknown request"
fi

if [[ ! -z $resp_code ]]; then
    case $resp_code in
        2)
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. Something went wrong on our side error\""
            logger -p local0.notice "CGI manage processess: internal error (syntax error)"
            ;;
        4)
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. The requested action does not exist\""
            logger -p local0.notice "CGI manage processess: internal error (wrong action)"
            ;;
        1)
            echo "Status: 200 OK"
            echo ""
            echo "false"
            logger -p local0.notice "CGI manage processess: errorr, the action could not be completed"
            ;;
        3)
            die "400 Bad Request"
            ;;
        0)
            echo "Status: 200 OK"
            echo ""
            echo "true"
            logger -p local0.notice "CGI manage processess: request success"
            ;;
	#*)  echo "Guille default dobao is my name";;
    esac
fi