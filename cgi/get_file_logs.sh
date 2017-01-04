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

OIFS="$IFS"
xcorrect=0
xerror=1

[[ $CONTENT_LENGTH -eq 0 ]] || read -n $CONTENT_LENGTH url
url="${url}&"
file=`echo ${url} | grep -oP '(?<=file=).*?(?=&)' | urldecode`

info=`cat /var/log/${file}`
rc=$?
echo "Content-Type: application/json"
echo "Status: 200 OK"
echo ""
if [[ rc -eq 0 ]]; then
    logs="["
    IFS=$'\n'
    for line in ${info}
    do
        logs="${logs}\"${line}\","
    done
    logs="${logs%?}]"
    echo "{\"rc\":true, \"logs\": ${logs}}"
else
    echo '{"rc": false}'
fi