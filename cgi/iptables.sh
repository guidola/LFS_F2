#!/usr/bin/env bash

die() {
    echo "Status: $1"
    echo""
    exit 0
}


(( $REQUEST_METHOD == "POST" )) || die "400 Bad Request"

IFS="$"
show=0
modify=1
insert=0
delete=1
xcorrect=0
xerror=1
esyntax=2
ecode=3

#verify we got all params we need.
(( ! -z  $CODI )) || CODI=${show}
[[ $CODI -ne 2 ]] || die "400 Bad Request"

#create return fifo
mkfifo "/web_server/fifos/acl/$$"

#send process request to process manager daemon
echo "$CODI\$$$\$$TABLE\$$ACTION\$$NUM\$$CHAIN\$$PROT\$$IINT\$$OINT\$$SOURCE\$$DEST\$$SPT\$$DPT\$$TO\$$TARGET" >> /web_server/fifos/acl/request

#wait for response from the authentication daemon
read resp_code

echo "Content-Type: text/html"



if [ ! -z resp_code ]; then
    case resp_code in
        ${esyntax})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "Oops." "Syntax error"
            ;;
        ${ecode})
            echo "Status: 500 Internal Server Error"
            echo ""
            echo "Oops." "The requested action does not exist"
            ;;
        ${xwrong})
            echo "Status: 200 OK"
            echo ""
            echo "false"
            ;;
        ${xcorrect})
            echo "Status: 200 OK"
            echo ""
            echo "true"
            ;;
    esac
fi