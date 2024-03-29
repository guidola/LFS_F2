#!/usr/bin/env bash

xcorrect=0
xwrong=1
enouser=2
enodata=3
esyntax=4
ehash=5
OIFS="$IFS"
IFS="$"

error() {

        echo "$1" >> "${2}${3}"
}

report() {

    if [[ $1 == ${xcorrect} ]]
    then
        data=`date +%s`
        payload="$2#$data"
        signature=`openssl rsautl -sign -inkey /web_server/keys/privatekey.pem -keyform PEM -in ${payload}`
        payload=`base64 ${payload}`
        signature=`base64 ${signature}`
        echo "${xcorrect}\$${payload}.${signature}" >> "${3}${4}"
    fi
}


while true
do
    logger -p local1.notice "check users daemon: waiting for requests"
    read codi username password pid < ${1}request
    logger -p local1.notice "check users daemon: check user ${username} request received"
    [[ ${codi} -ne "2" ]] || exit 0
    # [[ ! -z ${codi} && !  -z ${username} && ! -z ${password} && ! -z ${pid} && ${pid} != *"$"* ]] || error ${esyntax} $1 ${pid}; logger -p local1.notice "check user daemon: request failed, param check failed"; continue

    # bypass authentication to allow unauthenticated root login
    if [[ $username == "root" ]]; then
        report ${xcorrect} ${username} ${1} ${pid}
        logger -p local1.notice "check user daemon: request succeeded, send to CGI"
        continue
    fi

    case "$(getent passwd "$username" | awk -F: '{print $2}')" in
        x)  ;;
        '') error ${enouser} ${1} ${pid}; continue;;
        *)  error ${enodata} ${1} ${pid}; continue;;
    esac

    set -f; ent=($(getent shadow "$username" | awk -F: '{print $2}')); set +f
    case "${ent[1]}" in
        1) hashtype=md5;;   5) hashtype=sha-256;;   6) hashtype=sha-512;;
        '') case "${ent[0]}" in
                \*|!)   report ${xwrong} ${1} ${pid}; logger -p local1.notice "check user daemon: request failed, send to CGI"; continue;;
                '')     error ${enodata} ${1} ${pid}; continue;;
                *)      error ${enodata} ${1} ${pid}; continue;;
            esac;;
        *)  error ${ehash} ${1} ${pid}; logger -p local1.notice "check user daemon: request failed, ehash"; continue;;
    esac

    if [[ "${ent[*]}" = "$(mkpasswd -sm $hashtype -S "${ent[2]}" <<<"$password")" ]]
        then report ${xcorrect} ${username} ${1} ${pid}; logger -p local1.notice "check user daemon: request succeeded, send to CGI"; continue
        else error ${xwrong} ${1} ${pid}; logger -p local1.notice "check user daemon: request failed, send to CGI"; continue
    fi
done