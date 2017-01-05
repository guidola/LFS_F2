#!/usr/bin/env bash

getlist() {

    info=`cat /web_server/music/playlist.txt`
    missatge="{\"list\": ["
    i=1
    current=0
    IFS=$'\n'
    for line in $info
    do
        missatge="${missatge}\"${line}\","
        if [[ ${line} == ${song} ]]; then
            current=${i}
        fi
        let i=i+1
    done
    IFS=$OIFS
    missatge="${missatge%?}], \"current\": ${current}}"
}

play=0
pause_resume=1
next=2
previous=3
random=4
unrandom=5
repeat=6
unrepeat=7
xcorrect=0
xerror=1
esyntax=2
ecode=3
OIFS="$IFS"

while true
do
    #echo "Going to read from --> ${1}request"
    logger -p local1.notice "music player daemon: waiting for requests"
    IFS="$" read codi pid action song < ${1}request
    IFS="$OIFS"
    [[ ${codi} -ne "2" ]] || exit 0
    #echo "passed through first condition"
    [[ ! -z ${codi} && ! -z ${pid} && ${pid} != *"$"* ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
    #echo "passed through the conditions, going to answer to --> ${1}${pid} and the action is ${action}"
    case ${action} in
        ${play})
            #echo "entered to play song"
            logger -p local1.notice "music player daemon: play song ${song} request received"
            echo "S" > "${1}mpg123_fifo"
            echo "L /media/usb/music/${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: play song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: play song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
        ${pause_resume})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: pause/resume song request received"
            echo "P" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: pause/resume song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: pause/resume song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${next})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: next song request received"
            current=`cat /web_server/music/playlist.txt | grep -n ${song} | awk -F: '{print $1}'`
            total=`wc -l /web_server/music/playlist.txt | awk '{print $1}'`
            if [[ $current -ge $total ]]; then
                next=1
            else
                let next=current+1
            fi
            song=`cat /web_server/music/playlist.txt | awk -v var="$next" 'NR == var'`
            echo "S" > "${1}mpg123_fifo"
            echo "L /media/usb/music/${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: next song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: next song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${previous})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: previous song request received"
            current=`cat /web_server/music/playlist.txt | grep -n ${song} | awk -F: '{print $1}'`
            total=`wc -l /web_server/music/playlist.txt | awk '{print $1}'`
            if [[ $current -le 1 ]]; then
                previous=current
            else
                let previous=current-1
            fi
            song=`cat /web_server/music/playlist.txt | awk -v var="$previous" 'NR == var'`
            echo "S" > "${1}mpg123_fifo"
            echo "L /media/usb/music/${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: previous song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: previous song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
        ${random})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: random list request received"
            touch /web_server/music/randomlist.txt
            shuf /web_server/music/playlist.txt > /web_server/music/randomlist.txt
            cat /web_server/music/randomlist.txt > /web_server/music/playlist.txt
            song=`cat /web_server/music/playlist.txt | awk 'NR == 1'`
            echo "S" > "${1}mpg123_fifo"
            echo "L /media/usb/music/${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: random list request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: random list request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${unrandom})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: original list request received"
            cat /web_server/music/originallist.txt > /web_server/music/playlist.txt
            rm /web_server/music/randomlist.txt
            song=`cat /web_server/music/playlist.txt | awk 'NR == 1'`
            echo "S" > "${1}mpg123_fifo"
            echo "L /media/usb/music/${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: original list request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: original list request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${repeat})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: repeat song request received"
            touch /web_server/music/repeatlist.txt
            for i in `seq 1 30`
            do
                echo "${song}" >> /web_server/music/repeatlist.txt
            done
            cat /web_server/music/repeatlist.txt > /web_server/music/playlist.txt
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: repeat song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: repeat song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${unrepeat})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: unrepeat song request received"
            rm /web_server/music/repeatlist.txt
            cat /web_server/music/originallist.txt > /web_server/music/playlist.txt
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: unrepeat song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: unrepeat song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;

        *)
	    #echo "code error, going to answer to --> ${1}${pid}"
	    echo "${ecode}" >> "${1}${pid}"
	    #echo "answered done"
	    ;;
    esac
done