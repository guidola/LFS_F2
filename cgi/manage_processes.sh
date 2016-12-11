#!/usr/bin/env bash

die() {
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

#verify we got all params we need.
[[ ! -z  $ACTION || ! -z $PID || ! -z $TIME ]] || die "400 Bad Request"
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



if [[ ! -z $resp_code ]]; then
    case $resp_code in
        2)
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "Oops." "Something went wrong on our side" " error"
            ;;
        4)
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "Oops." "The requested action does not exist"
            ;;
        1)
            echo "Status: 200 OK"
            echo ""
            echo "false"
            ;;
        3)
            die "400 Bad Request"
            ;;
        0)
            echo "Status: 200 OK"
            echo ""
            echo "true"
            ;;
	#*)  echo "Guille default dobao is my name";;
    esac
fi