#!/usr/bin/env bash

kill=0
pause=1
xcorrect=0
xerror=1
esyntax=2
wpid=3
ecode=4
IFS="$"

while true
do
    
    read action request_pid time_to_sleep pid<$1

    [[ ${codi} == "2" ]] || exit 0
    [[ ! -z ${codi} || ! -z ${action} || ! -z ${request_pid} || ! -z ${pid} || ${pid} == *"$"* ]] || echo "${esyntax}" >> "${1}${pid}"
    [[ pid -ne -1 ]] || echo "${wpid}" >> "${1}${pid}"

    case ${action} in
        ${pause})   kill -STOP ${request_pid}
                    if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}${pid}"
                             ( sleep ${time_to_sleep}; kill -CONT ${request_pid})&
                        else echo "${xwrong}" >> "${1}${pid}"
                    fi;;
        ${kill})    kill ${request_pid}
                    if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}${pid}"
                        else echo "${xwrong}" >> "${1}${pid}"
                    fi;;
        *)          echo "${ecode}" >> "${1}${pid}";;
    esac


done