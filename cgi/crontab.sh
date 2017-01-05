#!/usr/bin/env bash

die() {
    logger -p local0.notice "CGI crontab: bad request"
    echo "Status: $1"
    echo""
    exit 0
}

urldecode(){
  echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x/g;')"
}


[[ $REQUEST_METHOD -eq "POST" ]] || die "400 Bad Request"

#IFS="$"
show=0
modify=1
insert=0
delete=1
xcorrect=0
xerror=1
esyntax=2
ecode=3

[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
CODI=`echo ${url} | grep -oP '(?<=codi=).*?(?=&)' | urldecode`
USER=`echo ${url} | grep -oP '(?<=user=).*?(?=&)' | urldecode`
ACTION=`echo ${url} | grep -oP '(?<=action=).*?(?=&)' | urldecode`
LINE_NUM=`echo ${url} | grep -oP '(?<=line_num=).*?(?=&)' | urldecode`
MINUTE=`echo ${url} | grep -oP '(?<=min=).*?(?=&)' | urldecode`
HOUR=`echo ${url} | grep -oP '(?<=hour=).*?(?=&)' | urldecode`
DOW=`echo ${url} | grep -oP '(?<=dow=).*?(?=&)' | urldecode`
DOM=`echo ${url} | grep -oP '(?<=dom=).*?(?=&)' | urldecode`
MONTH=`echo ${url} | grep -oP '(?<=month=).*?(?=&)' | urldecode`
COMMAND=`echo ${url} | grep -oP '(?<=command=).*?(?=&)' | urldecode`
TARGET_USER=`echo ${url} | grep -oP '(?<=target=).*?(?=&)' | urldecode`

#verify we got all params we need.
[[ ! -z  $CODI ]] || CODI=${modify}
[[ $CODI -ne 2 ]] || die "400 Bad Request"

#create return fifo
ret_fifo="/web_server/fifos/cron/$$"
mkfifo $ret_fifo
#echo "FIFO ${ret_fifo} created"

#send process request to process manager daemon
echo "1\$$$\$$USER\$$TARGET_USER\$$ACTION\$$LINE_NUM\$$MINUTE\$$HOUR\$$DOM\$$MONTH\$$DOW\$$COMMAND" >> /web_server/fifos/cron/request
#echo "Echo to request fifo done --> 1\$$$\$$USER\$$TARGET_USER\$$ACTION\$$LINE_NUM\$$MINUTE\$$HOUR\$$DOM\$$MONTH\$$DOW\$$COMMAND"
#wait for response from the authentication daemon
read resp_code < $ret_fifo
#echo "Read from return fifo done --> .${resp_code}."
echo "Content-Type: application/json"

if [[ $ACTION -eq $insert ]]; then
    logger -p local0.notice "CGI crontab: insert cron job request"
elif [[ $ACTION -eq $delete ]]; then
    logger -p local0.notice "CGI crontab: delete cron job request"
else
    logger -p local0.notice "CGI crontab: show cron jobs request"
fi

if [[ ! -z $resp_code ]]; then
    case $resp_code in
        ${esyntax})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. Syntax error\""
            logger -p local0.notice "CGI crontab: internal error (syntax error)"
            ;;
        ${ecode})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. The requested action does not exist\""
            logger -p local0.notice "CGI crontab: internal error (wrong action)"
            ;;
        ${xerror})
            echo "Status: 200 OK"
            echo ""
            echo '{"rc": false}'
            logger -p local0.notice "CGI crontab: error, the action could not be completed"
            ;;
        ${xcorrect})
            echo "Status: 200 OK"
            echo ""
            if [[ ! -z $ACTION ]]; then
                echo '{"rc": true}'
            else
                echo "Dobao is the JS king" >> "${ret_fifo}"
                read response < $ret_fifo
		        #echo "second read done"
                echo "{\"rc\":true, \"payload\": ${response}}"
            fi
            logger -p local0.notice "CGI crontab: request success"
            ;;
    esac
fi

