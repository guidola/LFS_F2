#!/usr/bin/env bash

die() {
    echo "Status: $1"
    echo""
    exit 0
}


(( $REQUEST_METHOD != "POST" )) || die "400 Bad Request"

IFS="$"
xcorrect=0
xwrong=1
esyntax=2
wpid=3
ecode=4

#verify we got all params we need.
(( -z  $ACTION || -z $PID || -z $TIME)) || die "400 Bad Request"

#create return fifo
mkfifo "/web_server/fifos/proc/$$"

#send process request to process manager daemon
echo "1\$$ACTION\$$PID\$$TIME\$$$" >> /web_server/fifos/proc/request

#wait for response from the authentication daemon
read resp_code

echo "Content-Type: text/html"



if [ ! -z resp_code ]; then
    case resp_code in
        ${esyntax})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "Oops." "Something went wrong on our side" " error"
            ;;
        ${ecode})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "Oops." "The requested action does not exist"
            ;;
        ${xwrong})
            echo "Status: 200 OK"
            echo ""
            echo "false"
            ;;
        ${wpid})
            die "400 Bad Request"
            ;;
        ${xcorrect})
            echo "Status: 200 OK"
            echo ""
            echo "true"
            ;;
    esac
fi