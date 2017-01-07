#!/usr/bin/env bash

generate_notification() {
    notification=`echo $template | sed -e "s/TITLE_PLACEHOLDER/$1/g"`
    notification=`echo $notification | sed -e "s/TEXT_PLACEHOLDER/$2/g"`
    notification=`echo $notification | sed -e "s/TYPE_PLACEHOLDER/$3/g"`
}

die() {
    logger -p local0.notice CGI auth: bad request
    echo "Status: $1"
    echo ""
    exit 0
}
urldecode(){
  echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x/g;')"
}

[[ $REQUEST_METHOD == "POST" ]] || die "400 Bad Request"
[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
USERNAME=`echo ${url} | grep -oP '(?<=username=).*?(?=&)' | urldecode`
PASSWD=`echo ${url} | grep -oP '(?<=passwd=).*?(?=&)' | urldecode`


IFS="$"
xcorrect=0
xwrong=1
enouser=2
enodata=3
esyntax=4
ehash=5

template=`cat ../www/js/templates/notification_template.js`
#verify we got all params we need.
(( ! -z  $USERNAME || ! -z $PASSWD )) || die "400 Bad Request"

#create return fifo
ret_fifo="/web_server/fifos/auth/$$"
mkfifo $ret_fifo

#send authentication request to authentication daemon
echo "1\$$USERNAME\$$PASSWD\$$$" >> /web_server/fifos/auth/request

#wait for response from the authentication daemon
read resp_code token < $ret_fifo

echo "Content-Type: text/html"



if [ ! -z resp_code ]; then
    case resp_code in
        ${xwrong}|${enouser}|${enodata})
            #return login.html with custom error
            echo "Status: 301 Forbidden"
            echo ""
            generate_notification "Invalid Credentials" "The username and password provided are not correct" "error"
            login=`cat /web_server/www/login.html | sed -e "s/\/\/CGI-SCRIPT-INJECTED-JS_____\/\//${notification}/g"`
            logger -p "local0.notice CGI auth: authentication failure"
            ;;
        ${esyntax}|${ehash})
            #return login.html with custom error
            echo "Status: 500 Internal Server Error"
            echo ""
            generate_notification "Oops." "Something went wrong on our side" "error"
            login=`cat /web_server/www/login.html | sed -e "s/\/\/CGI-SCRIPT-INJECTED-JS_____\/\//${notification}/g"`
            logger -p "local0.notice CGI auth: internal error"
            ;;
        ${xcorrect})
            #return index.html with dynamic attributes filled in and the token for the private area as a cookie
            echo "Status: 200 Ok"
            echo ""
            echo "Set-Cookie: auth_token=$token"
            index=`cat /web_server/www/index_prova.html | sed -e "s/{{username}}/${username}/g"`
            logger -p "local0.notice CGI auth: authentication success with token ${token}"
            ;;
    esac
fi