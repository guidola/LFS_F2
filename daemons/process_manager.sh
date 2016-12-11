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
    #echo "Going to read from --> ${1}request"
    read codi request_pid time_to_sleep pid < ${1}request
    #echo "codi: ${codi}\n rq_pid: ${request_pid}\n time_sleep: ${time_to_sleep}\n pid: ${pid}"

    [[ ${codi} -ne "2" ]] || exit 0
    #echo "passed through first condition"
    [[ ! -z ${codi} && ! -z ${request_pid} && ! -z ${pid} && ${pid} != *"$"* ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
    #echo "passed through second condition"
    [[ request_pid -ne -1 ]] || (echo "${wpid}" >> "${1}${pid}" & continue)

    #echo "passed through the conditions, going to answer to --> ${1}${pid}"

    case ${codi} in
        ${pause})
            #echo "it's a stop"
            kill -STOP ${request_pid}
            #echo "stop done"
            if [ $? -eq 0 ]
                then echo "${xcorrect}" >> "${1}${pid}"
                     ( sleep ${time_to_sleep}; kill -CONT ${request_pid})&
                     #echo "correct asnwered"
                else echo "${xerror}" >> "${1}${pid}"
                     #echo "error answered"
            fi;;
        ${kill})
            #echo "it's a kill"
            kill ${request_pid}
            #echo "kill done"
            if [ $? -eq 0 ]
                then echo "${xcorrect}" >> "${1}${pid}"
                     #echo "correct answered"
                else echo "${xerror}" >> "${1}${pid}"
                     #echo "error answered"
            fi;;
        *)
            #echo "it's the default"
            echo "${ecode}" >> "${1}${pid}"
            #echo "ecode answered";;
    esac


done