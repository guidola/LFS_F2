#!/usr/bin/env bash

die() {
    logger -p local0.notice "CGI iptables: bad request"
    echo "Status: $1"
    echo""
    exit 0
}

urldecode(){
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
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
TABLE=`echo ${url} | grep -oP '(?<=table=).*?(?=&)' | urldecode`
ACTION=`echo ${url} | grep -oP '(?<=action=).*?(?=&)' | urldecode`
NUM=`echo ${url} | grep -oP '(?<=num=).*?(?=&)' | urldecode`
CHAIN=`echo ${url} | grep -oP '(?<=chain=).*?(?=&)' | urldecode`
PROT=`echo ${url} | grep -oP '(?<=prot=).*?(?=&)' | urldecode`
IINT=`echo ${url} | grep -oP '(?<=iint=).*?(?=&)' | urldecode`
OINT=`echo ${url} | grep -oP '(?<=oint=).*?(?=&)' | urldecode`
SOURCE=`echo ${url} | grep -oP '(?<=source=).*?(?=&)' | urldecode`
DEST=`echo ${url} | grep -oP '(?<=dest=).*?(?=&)' | urldecode`
SPT=`echo ${url} | grep -oP '(?<=spt=).*?(?=&)' | urldecode`
DPT=`echo ${url} | grep -oP '(?<=dpt=).*?(?=&)' | urldecode`
TO=`echo ${url} | grep -oP '(?<=to=).*?(?=&)' | urldecode`
TARGET=`echo ${url} | grep -oP '(?<=target=).*?(?=&)' | urldecode`

#verify we got all params we need.
[[ ! -z  $CODI ]] || CODI=${modify}
[[ $CODI -ne 2 ]] || die "400 Bad Request"

#create return fifo
ret_fifo="/web_server/fifos/acl/$$"
mkfifo $ret_fifo
#echo "FIFO ${ret_fifo} created"

#send process request to process manager daemon
echo "$CODI\$$$\$$TABLE\$$ACTION\$$NUM\$$CHAIN\$$PROT\$$IINT\$$OINT\$$SOURCE\$$DEST\$$SPT\$$DPT\$$TO\$$TARGET" >> /web_server/fifos/acl/request
#echo "Echo to request fifo done --> $CODI\$$$\$$TABLE\$$ACTION\$$NUM\$$CHAIN\$$PROT\$$IINT\$$OINT\$$SOURCE\$$DEST\$$SPT\$$DPT\$$TO\$$TARGET"
#wait for response from the authentication daemon
read resp_code < $ret_fifo
#echo "Read from return fifo done --> .${resp_code}."
echo "Content-Type: application/json"

if [[ $ACTION -eq $insert ]]; then
    logger -p local0.notice "CGI iptables: insert rule request"
elif [[ $ACTION -eq $delete ]]; then
    logger -p local0.notice "CGI iptables: delete rule request"
else
    logger -p local0.notice "CGI iptables: show rules request"
fi

if [[ ! -z $resp_code ]]; then
    case $resp_code in
        ${esyntax})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. Syntax error\""
            logger -p local0.notice "CGI iptables: internal error (syntax error)"
            ;;
        ${ecode})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. The requested action does not exist\""
            logger -p local0.notice "CGI iptables: internal error (wrong action)"
            ;;
        ${xerror})
            echo "Status: 200 OK"
            echo ""
            echo '{"rc": false}'
            logger -p local0.notice "CGI iptables: error, the action could not be completed"
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
            logger -p local0.notice "CGI iptables: request success"
            ;;
    esac
fi


#example for insert (127 characters to read)
# codi=1&table=filter&action=0&num=3&chain=FORWARD&prot=tcp&iint=eth0&source=192.168.33.0/24&dest=0.0.0.0/0&dpt=8000&target=DROP
#example for delete (49 characters to read)
# codi=1&table=filter&action=1&num=3&chain=FORWARD
