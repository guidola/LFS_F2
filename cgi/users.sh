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
CODI=`echo ${url} | grep -oP '(?<=codi=).*?(?=&)'`
ACTION=`echo ${url} | grep -oP '(?<=action=).*?(?=&)'`
USERNAME=`echo ${url} | grep -oP '(?<=username=).*?(?=&)' | urldecode`
PASSWD=`echo ${url} | grep -oP '(?<=passwd=).*?(?=&)' | urldecode`
RNUMBER=`echo ${url} | grep -oP '(?<=rnumber=).*?(?=&)' | urldecode`
WPHONE=`echo ${url} | grep -oP '(?<=wphone=).*?(?=&)' | urldecode`
HPHONE=`echo ${url} | grep -oP '(?<=hphone=).*?(?=&)' | urldecode`
OTHER=`echo ${url} | grep -oP '(?<=other=).*?(?=&)' | urldecode`
FULLNAME=`echo ${url} | grep -oP '(?<=fullname=).*?(?=&)' | urldecode`

if [[ ! -z $ACTION ]]; then

    [[ $CODI -ne 2 ]] || die "400 Bad Request"

    #create return fifo
    ret_fifo="/web_server/fifos/usr/$$"
    mkfifo $ret_fifo
    echo "FIFO ${ret_fifo} created"

    #send process request to process manager daemon
    echo "1\$$$\$$ACTION\$$USERNAME\$$PASSWD\$$FULLNAME\$$RNUMBER\$$WPHONE\$$HPHONE\$$OTHER" >> /web_server/fifos/usr/request
    echo "Echo to request fifo done --> 1\$$$\$$ACTION\$$USERNAME\$$PASSWD\$$FULLNAME\$$RNUMBER\$$WPHONE\$$HPHONE\$$OTHER"
    #wait for response from the authentication daemon
    read resp_code < $ret_fifo
    echo "Read from return fifo done --> .${resp_code}."
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
                echo '{"rc": true}'
                ;;
        esac
    fi
else
    info=`cat /etc/passwd`
    message='{"users": ['
    OIFS=$IFS
    IFS=$'\n'
    for line in $info
    do
    basic_info=`echo ${line} | awk -F: '{print "{\"usr\": \"" $1 "\", \"passwd\": \"" $2 "\", \"uid\": " $3 ", \"gid\": " $4 ", "}'`
    message="${message}${basic_info}"
    additional_info=`echo ${line} | awk -F: '{print $5}' | awk -F, '{print "\"fullname\": \"" $1 "\", \"rnumber\": " $2 ", \"wphone\": " $3 ", \"hphone\": " $4 ", \"other\": \"" $5 "\", "  }'`
    message="${message}${additional_info}"
    final_info=`echo ${line} | awk -F: '{print "\"home\": \"" $6 "\", \"shell\": \"" $7 "\"},"}'`
    message="${message}${final_info}"
    done
    IFS=$OIFS
    message="${message%?}]}"
    echo "Status: 200 OK"
    echo ""
    echo "$message"
fi