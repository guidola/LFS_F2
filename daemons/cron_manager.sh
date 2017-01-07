#!/usr/bin/env bash

show=0
modify=1
insert=0
delete=1
xcorrect=0
xerror=1
esyntax=2
ecode=3
OIFS="$IFS"

while true
do
    #echo "Going to read from --> ${1}request"
    logger -p local1.notice "cron manager daemon: waiting for requests"
    IFS="$" read codi pid user target_user action line_num minute hour monthday month weekday command < ${1}request
    IFS="$OIFS"
    [[ ${codi} -ne "2" ]] || exit 0
    #echo "passed through first condition"
    [[ ! -z ${codi} && ! -z ${user} && ! -z ${pid} && ${pid} != *"$"* ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
    #echo "passed through the conditions, going to answer to --> ${1}${pid} and the code is ${codi}"
    [[ ! -z ${action} ]] || codi=${show}
    #echo "codi and action: ${codi}, ${action}"
    case ${codi} in
        ${show})
            #echo "entered to show cron jobs"
            logger -p local1.notice "cron manager daemon: show cron jobs request received"
            message='{"cron":['
            if [[ $user == "root" ]]; then
                #echo "the user is root"
                for usr in $(cut -f1 -d: /etc/passwd)
                do
                    jobs=`crontab -u ${usr} -l 2> /dev/null | grep "^[^#]"`
                    if [[ ! -z $jobs && $jobs != *"no crontab for"* ]]
                    then
                        message="${message}{\"user\": \"${usr}\", \"jobs\":["
                        IFS=$'\n'
                        i=1
                        for line in $jobs
                        do
                            info=`echo ${line} | awk -v var=${i} '{print "{\"line_num\": " var ", \"min\": \"" $1 "\", \"hour\": \"" $2 "\", \"dom\": \"" $3 "\", \"month\": \"" $4 "\", \"dow\": \"" $5 "\", "}'`
                            message="${message}${info}"
                            info=`echo ${line} | awk '{$1=$2=$3=$4=$5=""; print $0 }' | sed 's/"/\\\U0022/g' `
                            message="${message} \"command\": \"${info}\"},"
                            let i=i+1
                        done
                        IFS=$OIFS
                        if [[ ${message:${#message}-1:1} == "[" ]]; then
                            message="${message}]},"
                        else
                            message="${message%?}]},"
                        fi
                    fi
                done
                if [[ ${message:${#message}-1:1} == "[" ]]; then
                    message="${message}]}"
                else
                    message="${message%?}]}"
                fi
            else
                #echo "the user is not root"
                jobs=`crontab -u ${user} -l 2> /dev/null | grep "^[^#]"`
                if [[ ! -z $jobs && $jobs != *"no crontab for"* ]]
                then
                    message="${message}{\"user\": \"${user}\", \"jobs\":["
                    IFS=$'\n'
                    i=1
                    for line in $jobs
                    do
                        info=`echo ${line} | awk -v var=${i} '{print "{\"line_num\": " var ", \"min\": \"" $1 "\", \"hour\": \"" $2 "\", \"dom\": \"" $3 "\", \"month\": \"" $4 "\", \"dow\": \"" $5 "\", "}'`
                        message="${message}${info}"
                        info=`echo ${line} | awk '{$1=$2=$3=$4=$5=""; print "\"command\": \"" $0 "\"},"}'`
                        message="${message}${info}"
                        let i=i+1
                    done
                    IFS=$OIFS
                    if [[ ${message:${#message}-1:1} == "[" ]]; then
                        message="${message}]}]}"
                    else
                        message="${message%?}]}]}"
                    fi
                fi
            fi
            #echo "finished parsing cron, the content is:"
            #echo "${message}"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "cron manager daemon: show cron jobs request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            echo "${message}" >> "${1}${pid}"
            logger -p local1.notice "cron manager daemon: show cron jobs request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        ;;

        ${modify})
	        #echo "entered to modify command"
            [[ ! -z ${action} ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
            #echo "there is action"
            if [[ ${user} != "root" ]]; then
                target_user=${user}
            fi
            touch /web_server/tmp/cron/${target_user}
            if [[ ${action} -eq ${delete} ]]; then
                logger -p local1.notice "cron manager daemon: delete cron job number ${line_num} from user ${target_user} request received"
		        #echo "the action is delete"
                crontab -u ${target_user} -l | grep "^[^#]" | sed "${line_num}d" > /web_server/tmp/cron/${target_user}
                crontab -u ${target_user} /web_server/tmp/cron/${target_user}
                rc=$?
                rm /web_server/tmp/cron/${target_user}
                crontab -u ${target_user} -l 2>>/dev/null
                rc2=$?
                rm /web_server/tmp/cron/${target_user}
                #echo "command finished, going to answer to --> ${1}${pid}"
                if [ ${rc} -eq 0 && ${rc2} -eq 0 ]
                    then echo "${xcorrect}" >> "${1}${pid}"; logger -p local1.notice "cron manager daemon: request succeeded, send to CGI"
                    else echo "${xerror}" >> "${1}${pid}"; logger -p local1.notice "cron manager daemon: request failed, send to CGI"
                fi
                #echo "answered done"
            else if [[ ${action} -eq ${insert} ]]; then
                     logger -p local1.notice "cron manager daemon: insert cron job from user ${target_user} request received"
		             #echo "the action is insert"
                     crontab -u ${target_user} -l | grep "^[^#]" > /web_server/tmp/cron/${target_user}
                     echo "${minute} ${hour} ${monthday} ${month} ${weekday} ${command}" >> /web_server/tmp/cron/${target_user}
                     crontab -u ${target_user} /web_server/tmp/cron/${target_user}
                     rc=$?
                     crontab -u ${target_user} -l 2>>/dev/null
                     rc2=$?
                     rm /web_server/tmp/cron/${target_user}
                     #echo "command finished, going to answer to --> ${1}${pid}"
                     if [ ${rc} -eq 0 && ${rc2} -eq 0 ]
                        then echo "${xcorrect}" >> "${1}${pid}"; logger -p local1.notice "cron manager daemon: request succeeded, send to CGI"
                        else echo "${xerror}" >> "${1}${pid}"; logger -p local1.notice "cron manager daemon: request failed, send to CGI"
                     fi
                     #echo "answered done"
                 else
		             #echo "syntax error, going to answer to --> ${1}${pid}"
                     echo "${esyntax}" >> "${1}${pid}"
		             #echo "answered done"
                 fi
            fi;;
        *)
	    #echo "code error, going to answer to --> ${1}${pid}"
	    echo "${ecode}" >> "${1}${pid}"
	    #echo "answered done"
	    ;;
    esac
done