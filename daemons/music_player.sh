#!/usr/bin/env bash

getlist() {

    info=`cat /web_server/music/${usb}/playlist.txt`
    missatge="{\"list\": ["

    for line in $info
    do
        missatge="${missatge}\"${line}\","
    done

    if [[ ${missatge:${#missatge}-1:1} == "[" ]]; then
        missatge="${missatge}], \"current\": ${current}}"
    else
        missatge="${missatge%?}], \"current\": ${current}}"
    fi
}

current=-1
play=0
pause_resume=1
next=2
previous=3
random=4
unrandom=5
repeat=6
unrepeat=7
show=8
stop=9
xcorrect=0
xerror=1
esyntax=2
ecode=3
OIFS="$IFS"
isrepeat=0

while true
do
    #echo "Going to read from --> ${1}request"
    logger -p local1.notice "music player daemon: waiting for requests"
    IFS="$" read codi pid action usb song < ${1}request
    IFS="$OIFS"
    [[ ${codi} -ne "2" ]] || exit 0
    #echo "passed through first condition"
    [[ ! -z ${codi} && ! -z ${pid} && ${pid} != *"$"* ]] || (echo "${esyntax}" >> "${1}${pid}" & continue)
    #echo "passed through the conditions, going to answer to --> ${1}${pid} and the action is ${action}"
    logger -p local1.notice "music player daemon: received a petition with code $action, usb $usb and song $song"
    case ${action} in
        ${play})
            #echo "entered to play song"
            logger -p local1.notice "music player daemon: play song ${song} from usb ${usb} request received"
            echo "S" > "${1}mpg123_fifo"
            echo "L ${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: play song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            current_song=${song}
            current=`cat /web_server/music/${usb}/playlist.txt | grep -n ${current_song} | awk -F: '{print $1}'`
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: play song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
        ${pause_resume})
            #echo "entered to pause/resume song"
            logger -p local1.notice "music player daemon: pause/resume song from usb ${usb} request received"
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
            #echo "entered to next song"
            logger -p local1.notice "music player daemon: next song from usb ${usb} request received"
            if [[ $isrepeat -eq 1 ]]; then
                song=${current_song}
                echo "L ${song}" > "${1}mpg123_fifo"
                next_song=$current
            else
                total=`wc -l /web_server/music/${usb}/playlist.txt | awk '{print $1}'`
                if [[ $current -ge $total ]]; then
                    let next_song=1
                else
                    let next_song=current+1
                fi
                current_song=`cat /web_server/music/${usb}/playlist.txt | awk -v var="$next_song" 'NR == var'`
                echo "S" > "${1}mpg123_fifo"
                echo "L ${current_song}" > "${1}mpg123_fifo"
            fi
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: next song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            current=$next_song
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: next song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${previous})
            #echo "entered to previous song"
            logger -p local1.notice "music player daemon: previous song from usb ${usb} request received"
            if [[ $isrepeat -eq 1 ]]; then
                song=${current_song}
                echo "L ${song}" > "${1}mpg123_fifo"
                previous_song=$current
            else
                total=`wc -l /web_server/music/${usb}/playlist.txt | awk '{print $1}'`
                if [[ $current -le 1 ]]; then
                    let previous_song=1 # la posem a 0 i no a current per desinicialitzar el -1
                else
                    let previous_song=current-1
                fi
                current_song=`cat /web_server/music/${usb}/playlist.txt | awk -v var="$previous_song" 'NR == var'`
                echo "S" > "${1}mpg123_fifo"
                echo "L ${current_song}" > "${1}mpg123_fifo"
            fi

            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: previous song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            current=$previous_song
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: previous song request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
        ${random})
            #echo "entered to random list"
            logger -p local1.notice "music player daemon: random list from usb ${usb} request received"
            touch /web_server/music/${usb}/randomlist.txt
            shuf /web_server/music/${usb}/playlist.txt > /web_server/music/${usb}/randomlist.txt
            cat /web_server/music/${usb}/randomlist.txt > /web_server/music/${usb}/playlist.txt
            song=`cat /web_server/music/${usb}/playlist.txt | awk 'NR == 1'`
            echo "S" > "${1}mpg123_fifo"
            echo "L ${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: random list request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            current=1
            current_song=${song}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: random list request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${unrandom})
            #echo "entered to unrandom list"
            logger -p local1.notice "music player daemon: original list from usb ${usb} request received"
            cat /web_server/music/${usb}/originallist.txt > /web_server/music/${usb}/playlist.txt
            rm /web_server/music/${usb}/randomlist.txt
            song=`cat /web_server/music/${usb}/playlist.txt | awk 'NR == 1'`
            echo "S" > "${1}mpg123_fifo"
            echo "L ${song}" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: original list request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            current=1
            current_song=${song}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: original list request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${repeat})
            #echo "entered to repeat song"
            logger -p local1.notice "music player daemon: repeat song from usb ${usb} request received"
            isrepeat=1
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
            #echo "entered to unrepeat song"
            logger -p local1.notice "music player daemon: unrepeat song from usb ${usb} request received"
            isrepeat=0
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
	    ${show})
            #echo "entered to show list"
            logger -p local1.notice "music player daemon: show list from usb ${usb} request received"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: show list request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: show list request finished, information send to CGI"
	        #echo "asnwered with the message to --> ${1}${pid}"
	        #echo "the message is: ${missatge}"
	        ;;
	    ${stop})
            #echo "entered to stp` song"
            logger -p local1.notice "music player daemon: stop song from usb ${usb} request received"
            echo "S" > "${1}mpg123_fifo"
            echo "${xcorrect}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: stop song request succeeded, waiting for response"
            #echo "asnwered with xcorrect to --> ${1}${pid}"
            read brossa < ${1}${pid}
            current_song=""
            current=-1
            getlist
            echo "${missatge}" >> "${1}${pid}"
            logger -p local1.notice "music player daemon: stop song request finished, information send to CGI"
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