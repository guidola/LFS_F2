#!/usr/bin/env bash

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
    logger -p local1.notice "user manager daemon: waiting for requests"
    IFS="$" read codi pid action username passwd fullname rnumber wphone hphone other < ${1}request
    IFS="$OIFS"
    [[ ${codi} -ne "2" ]] || exit 0
    #echo "passed through first condition"
    [[ ! -z ${codi} && ! -z ${pid} && ${pid} != *"$"* && ! -z ${action} ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
    #echo "passed through the conditions, going to answer to --> ${1}${pid} and the code is ${codi}"

    case ${action} in
        ${insert})
            logger -p local1.notice "user manager daemon: create user ${username} request received"
            #echo "entered to insert command"
            [[ ! -z ${username} && ! -z ${passwd} ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
            adduser "$username" <<EOF
            $passwd
            $passwd
            $fullname
            $rnumber
            $wphone
            $hphone
            $other
            "Y"
EOF
            rc=$?
            #echo "command finished, going to answer to --> ${1}${pid}"
            if [ ${rc} -eq 0 ]
                then echo "${xcorrect}" >> "${1}${pid}"; logger -p local1.notice "user manager daemon: request succeeded, send to CGI"
                else echo "${xerror}" >> "${1}${pid}"; logger -p local1.notice "user manager daemon: request failed, send to CGI"
            fi;;
        ${delete})
            logger -p local1.notice "user manager daemon: delete user ${username} request received"
	        #echo "entered to delete command"
	        [[ ! -z ${username} ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
            userdel "$username"
            rc=$?
            rm -rf /home/${username}
	        rc2=$?
            #echo "command finished, going to answer to --> ${1}${pid}"
            if [[ ${rc} -eq 0 && ${rc2} -eq 0 ]]
                then echo "${xcorrect}" >> "${1}${pid}"; logger -p local1.notice "user manager daemon: request succeeded, send to CGI"
                else echo "${xerror}" >> "${1}${pid}"; logger -p local1.notice "user manager daemon: request failed, send to CGI"
            fi;;

        *)
	    #echo "code error, going to answer to --> ${1}${pid}"
	    echo "${ecode}" >> "${1}${pid}"
	    #echo "answered done"
	    ;;
    esac
done