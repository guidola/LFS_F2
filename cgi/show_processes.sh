#!/usr/bin/env bash


OIFS="$IFS"

strings=`top -n 1 -b | awk '{print $8 "$" $1 "$" $2 "$" $12 "$" $10 "$" $9 "$" $11}' | tail -n +8`
#strings=`top -n 1 -b | awk '{print $10 "$" $1 "$" $2 "$" $11 $12 "$" $18 "$" $7 "$" $9}' | tail -n +8 | sed "s/'-//g"`
echo "Content-Type: application/json"
echo ""
echo "{"
echo "  \"processes\":["
lines=`echo "$strings" | wc -l`
let true_lines=lines-1
i=1;
for string in ${strings}; do
    IFS="$"
    set $string
    Args="$*"
    if [ $i -eq $lines ]; then
        echo "  ]}"
    else if [ $i -eq "$true_lines" ]; then
            echo "      {\"status\":\"$1\", \"pid\":\"$2\", \"user\":\"$3\", \"command\":\"$4\", \"memory\":\"$5\", \"cpu\":\"$6\", \"cputime\":\"$7\"}"
        else
            echo "      {\"status\":\"$1\", \"pid\":\"$2\", \"user\":\"$3\", \"command\":\"$4\", \"memory\":\"$5\", \"cpu\":\"$6\", \"cputime\":\"$7\"},"
        fi
    fi

    IFS="$OIFS"
    let i=i+1
done

logger -p local0.notice "CGI show processess: request completed"

