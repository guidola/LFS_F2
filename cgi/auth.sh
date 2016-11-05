#!/usr/bin/env bash

generate_notification() {
    notification=`echo $template | sed -e "s/TITLE_PLACEHOLDER/$1/g"`
    notification=`echo $notification | sed -e "s/TEXT_PLACEHOLDER/$2/g"`
    notification=`echo $notification | sed -e "s/TYPE_PLACEHOLDER/$3/g"`
}

die() {
    echo "Status: $1"
    exit 0
}


(( $REQUEST_METHOD != "POST" )) || die "400 Bad Request"

IFS="$"
xcorrect=0
xwrong=1
enouser=2
enodata=3
esyntax=4
ehash=5

template=`cat /web_server/www/js/notification_template.js`
#verify we got all params we need.
(( -z  $USERNAME || -z $PWD )) || die "400 Bad Request"

#create return fifo
mkfifo "/web_server/fifos/auth/$$"

#send authentication request to authentication daemon
echo "1\$$USERNAME\$$PWD\$$$" >> /web_server/fifos/auth/request

#wait for response from the authentication daemon
read resp_code token

echo "Content-Type: text/html"



if [ ! -z resp_code ]; then
    case resp_code in
        ${xwrong}|${enouser}|${enodata})
            #return login.html with custom error
            generate_notification "Invalid Credentials" "The username and password provided are not correct" "error"
            login=`cat /web_server/www/login.html | sed -e "s/\/\/CGI-SCRIPT-INJECTED-JS_____\/\//${notification}/g"`
            ;;
        ${esyntax}|${ehash})
            #return login.html with custom error
            generate_notification "Oops." "Something went wrong on our side" "error"
            login=`cat /web_server/www/login.html | sed -e "s/\/\/CGI-SCRIPT-INJECTED-JS_____\/\//${notification}/g"`
            ;;
        ${xcorrect})
            #return index.html with dynamic attributes filled in and the token for the private area as a cookie
            echo "Set-Cookie: auth_token=$token"
            index=`cat /web_server/www/index.html | sed -e "s/{{username}}/${username}/g"`
            ;;
    esac
fi