#!/usr/bin/env bash


die() {
    logger -p local0.notice CGI auth: bad request
    echo "Status: $1"
    echo ""
    exit 0
}

urldecode(){
  read a
  echo -e "`echo ${a} | sed 's/+/ /g;s/%\(..\)/\\\x\1/g;'`"
}

[[ $REQUEST_METHOD == "POST" ]] || die "400 Bad Request"
[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
username=`echo ${url} | grep -oP '(?<=username=).*?(?=&)' | urldecode`
passwd=`echo ${url} | grep -oP '(?<=pwd=).*?(?=&)' | urldecode`


IFS="$"
xcorrect=0
xwrong=1
enouser=2
enodata=3
esyntax=4
ehash=5


#verify we got all params we need.
[[ ! -z  username && ! -z passwd ]] || die "400 Bad Request"

#create return fifo
ret_fifo="/web_server/fifos/auth/$$"
mkfifo $ret_fifo
#send authentication request to authentication daemon
echo "1\$$username\$$passwd\$$$" >> /web_server/fifos/auth/request
#wait for response from the authentication daemon
read resp_code token < $ret_fifo

echo "Content-Type: text/html"



if [[ ! -z $resp_code ]]; then
    case $resp_code in
        ${xwrong}|${enouser}|${enodata})
            #return login.html with custom error
            echo "Status: 303 See Other"
            echo "Location: /login.html#1"
            echo ""

            logger -p local0.notice "CGI auth: authentication failure"
            ;;
        ${esyntax}|${ehash})
            #return login.html with custom error
            echo "Status: 303 See Other"
            echo "Location: /login.html#2"
            echo ""
            logger -p local0.notice "CGI auth: internal error"
            ;;
        ${xcorrect})
            #return index.html with dynamic attributes filled in and the token for the private area as a cookie
            echo "Status: 303 See Other"
            echo "Set-Cookie: authenticated=true; path=/"
            echo "Set-Cookie: username=${username}; path=/"
            echo "Location: /"
            echo ""
            logger -p local0.notice "CGI auth: authentication success with token ${token}"
            ;;
        *)
            echo "Status: 303 See Other"
            echo "Location: /login.html#2"
            echo ""
            ;;
    esac
else
    echo "Status: 303 See Other"
    echo "Location: /login.html#2"
    echo ""
fi