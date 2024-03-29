#!/usr/bin/env bash

die() {
    logger -p local0.notice "CGI get file logs: bad request"
    echo "Status: $1"
    echo""
    exit 0
}

urldecode(){
  read a
  echo -e "`echo ${a} | sed 's/+/ /g;s/%\(..\)/\\\x\1/g;'`"
}

[[ $REQUEST_METHOD -eq "POST" ]] || die "400 Bad Request"

OIFS="$IFS"
xcorrect=0
xerror=1

[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
file=`echo ${url} | grep -oP '(?<=file=).*?(?=&)' | urldecode`
logger -p local0.notice "CGI get file logs: get logs from file ${file} request"
info=`tail -n 5000 ${file}`
rc=$?
echo "Content-Type: application/json"
echo "Status: 200 OK"
echo ""
if [[ rc -eq 0 ]]; then
    logs="["
    IFS=$'\n'
    for line in ${info}
    do
        line=`echo $line | tr "\t" " " | tr "\n" " " | tr '"' "'"`
        logs="${logs}\"${line}\","
    done
    if [[ ${logs:${#logs}-1:1} == "[" ]]; then
        logs="${logs}]"
    else
        logs="${logs%?}]"
    fi
    echo "{\"rc\":true, \"logs\": ${logs} }"
    logger -p local0.notice "CGI get file logs: success"
else
    echo '{"rc": false}'
    logger -p local0.notice "CGI get file logs: error, the action could not be completed"
fi