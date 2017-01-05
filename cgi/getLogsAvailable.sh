#!/usr/bin/env bash

# list the logs folder /var/log and create a json with all the .log files to show em as options on the side-menu

lsToJson() {

    first=1
    echo "["

    for node in *; do
        if [[ $node == '.' || $node == '..' || "$node" == '*' ]]; then continue; fi

        #if its a file .log put it on the json
        if [[ -f ${node} ]]; then
            if [[ ${node} =~ \.log$ ]]; then
                if [[ $first -ne 1 ]]; then
                    echo ", { \"type\": \"file\", \"name\": \"${node::${#node}-4}\", \"path\": \"`pwd`/${node}\" }"
                else
                    echo "{ \"type\": \"file\", \"name\": \"${node::${#node}-4}\", \"path\": \"`pwd`/${node}\" }"
                    first=0
                fi
            else
                last_node=""
            fi
        fi

        #if its a folder call this func and put pre and post brackets for next json depth
        if [[ -d ${node} ]]; then
            cd ${node} 2>>/dev/null
            if [[ $? -ne 0 ]]; then continue; fi
            if [[ $first -ne 1 ]]; then
                echo ","
            else
                first=0
            fi
            echo "{ \"type\": \"folder\", \"name\": \"${node}\", \"childs\": "
            lsToJson
            cd ..
            echo "}"
        fi

    done;

    echo "${last_node}]"
    first=0
}


# enter /var/log to avoid static paths
cd /var/log/

# echo the header
echo "Status: 200 Ok"
echo "Content-Type: application/json"
echo ""

lsToJson
logger -p local0.notice "CGI get logs available: success"