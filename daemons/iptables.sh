#!/usr/bin/env bash

show=0
modify=1
xcorrect=0
xerror=1
esyntax=2
wpid=3
ecode=4
IFS="$"

while true
do
    
    read codi pid num pkts target prot iint oint source dest spt dpt to <$1

    [[ ${codi} == "2" ]] || exit 0
    [[ ! -z ${codi}   ! -z ${pid} || ${pid} == *"$"* ]] || echo "${esyntax}" >> "${1}${pid}"
    [[ pid -ne -1 ]] || echo "${wpid}" >> "${1}${pid}"

    case ${codi} in
        ${show})   kill -STOP ${request_pid}
                    if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}${pid}"
                             ( sleep ${time_to_sleep}; kill -CONT ${request_pid})&
                        else echo "${xwrong}" >> "${1}${pid}"
                    fi;;
        ${modify})    kill ${request_pid}
                    if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}${pid}"
                        else echo "${xwrong}" >> "${1}${pid}"
                    fi;;
        *)          echo "${ecode}" >> "${1}${pid}";;
    esac


done