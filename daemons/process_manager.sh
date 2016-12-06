#!/usr/bin/env bash

cont=0
pause=1
kill=2
xcorrect=0
xerror=1
esyntax=2
ecode=4
IFS="$"


report() {

        echo "${1}" >> "${2}"
}


while true
do
    
    read codi pid<$1

    [[ ! -z ${codi} || ! -z ${pid} || ${pid} == *"$"* ]] || echo "${esyntax}" >> "${1}"

    case ${codi} in
        ${cont})    kill -CONT ${pid}
                    if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}"
                        else echo "${xwrong}" >> "${1}"
                    fi;;
        ${pause})   kill -STOP ${pid}
                    if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}"
                        else echo "${xwrong}" >> "${1}"
                    fi;;
        ${kill})    kill ${pid}
                    if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}"
                        else echo "${xwrong}" >> "${1}"
                    fi;;
        *)          echo "${ecode}" >> "${1}";;
    esac


done