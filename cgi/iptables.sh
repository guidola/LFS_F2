#!/usr/bin/env bash

die() {
    echo "Status: $1"
    echo""
    exit 0
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

read -n $CONTENT_LENGTH url
url="${url}&"
CODI=`echo ${url} | grep -oP '(?<=codi=).*?(?=&)'`
TABLE=`echo ${url} | grep -oP '(?<=table=).*?(?=&)'`
ACTION=`echo ${url} | grep -oP '(?<=action=).*?(?=&)'`
NUM=`echo ${url} | grep -oP '(?<=num=).*?(?=&)'`
CHAIN=`echo ${url} | grep -oP '(?<=chain=).*?(?=&)'`
PROT=`echo ${url} | grep -oP '(?<=prot=).*?(?=&)'`
IINT=`echo ${url} | grep -oP '(?<=iint=).*?(?=&)'`
OINT=`echo ${url} | grep -oP '(?<=oint=).*?(?=&)'`
SOURCE=`echo ${url} | grep -oP '(?<=source=).*?(?=&)'`
DEST=`echo ${url} | grep -oP '(?<=dest=).*?(?=&)'`
SPT=`echo ${url} | grep -oP '(?<=spt=).*?(?=&)'`
DPT=`echo ${url} | grep -oP '(?<=dpt=).*?(?=&)'`
TO=`echo ${url} | grep -oP '(?<=to=).*?(?=&)'`
TARGET=`echo ${url} | grep -oP '(?<=target=).*?(?=&)'`

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



if [[ ! -z $resp_code ]]; then
    case $resp_code in
        ${esyntax})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. Syntax error\""
            ;;
        ${ecode})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "\"Oops. The requested action does not exist\""
            ;;
        ${xerror})
            echo "Status: 200 OK"
            echo ""
            echo '{"rc": false}'
            ;;
        ${xcorrect})
            echo "Status: 200 OK"
            echo ""
            if [[ $CODI -ne $show ]]; then
                echo '{"rc": true}'
            else
                echo "Dobai is the JS king" >> "${ret_fifo}"
                read response < $ret_fifo
		        echo "second read done"
                echo "{\"rc\":true, \"payload\": $response"
            fi
            ;;
    esac
fi


#example for insert (127 characters to read)
# codi=1&table=filter&action=0&num=3&chain=FORWARD&prot=tcp&iint=eth0&source=192.168.33.0/24&dest=0.0.0.0/0&dpt=8000&target=DROP
#example for delete (49 characters to read)
# codi=1&table=filter&action=1&num=3&chain=FORWARD
