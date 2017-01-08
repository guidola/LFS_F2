#!/usr/bin/env bash

shutdown=0
restart=1
xcorrect=0
xerror=1
esyntax=2
ecode=3
OIFS="$IFS"

while true
do
    #echo "Going to read from --> ${1}request"
    logger -p local1.notice "boot manager daemon: waiting for requests"
    IFS="$" read codi pid action < ${1}request
    IFS="$OIFS"
    [[ ${codi} -ne "2" ]] || exit 0
    #echo "passed through first condition"
    [[ ! -z ${codi} && ! -z ${pid} && ${pid} != *"$"* ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
    #echo "passed through the conditions, going to answer to --> ${1}${pid} and the action is ${action}"
    case ${action} in
        ${shutdown})
            #echo "entered to shutdown"
            logger -p local1.notice "boot manager daemon: shutdown request received"
            echo "${xcorrect}" >> "${1}${pid}";
            logger -p local1.notice "boot manager daemon: shutdown request success"
	        ( sleep 5; poweroff )&
	        ;;
        ${restart})
            #echo "entered to restart"
            logger -p local1.notice "boot manager daemon: restart request received"
            echo "${xcorrect}" >> "${1}${pid}";
            logger -p local1.notice "boot manager daemon: restart request success"
            ( sleep 5; reboot )&
	        ;;
        *)
	    #echo "code error, going to answer to --> ${1}${pid}"
	    echo "${ecode}" >> "${1}${pid}"
	    #echo "answered done"
	    ;;
    esac
done