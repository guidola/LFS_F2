#!/bin/sh

OIFS="$IFS"

cpu=`top -n 1 | awk 'NR == 3 {print $2 "$" $6 "$" $4 "$" $10 "$" $12 "$" $14 "$" $16 "$" $8 }'`
IFS="$"
set $cpu
#Args="$*"
IFS="$OIFS"

echo "Content-Type: application/json"
echo ""
echo "{"
echo "  \"cpu\":["
echo "      $1,"            #cpu_usr
echo "      $2,"            #cpu_nice
echo "      $3,"            #cpu_sys
echo "      $4,"            #cpu_iowait
echo "      $5,"            #cpu_irq
echo "      $6,"            #cpu_soft
echo "      $7,"            #cpu_steal
echo "      $8"             #cpu-idle
echo "  ],"

mem=`free -m | awk 'NR == 2 {print $3 "$" $4 "$" $6 "$" $5 "$" $7 }'`
IFS="$"
set $mem
#Args="$*"
IFS="$OIFS"

echo "  \"mem\":["
echo "      $1,"            #mem_used
echo "      $2,"            #mem_free
echo "      $3,"            #mem_cache
echo "      $4,"            #mem_shared
echo "      $5"             #mem_avail
echo "  ],"

disk=`df 2>/dev/null | awk '{if($6=="/") print $5 }' | sed -e 's/%//g'`

hostname=`hostname`

uptime_since=`uptime -s`
uptime_for=`uptime -p`

active_users=`uptime | awk '{print $4}'`
load_average_15m=`uptime | awk '{print $10}'`

strings=`last -F | head -n 10 | awk '{if($1!="reboot" && $1!="wtmp" && $0!="") if( $2 ~ /pts/ ){if($9=="-"){print $1 "$remote$" $3 "$" $6 "_" $5 "_" $8 "_" $7 "$" $12 "_" $11 "_" $14 "_" $13}else{print $1 "$remote$" $3 "$" $6 "_" $5 "_" $8 "_" $7 "$-"}}else{if( $3 ~ /:/ ) {if($9=="-"){print $1 "$local$" $2 "$$" $6 "_" $5 "_" $8 "_" $7 "$" $12 "_" $11 "_" $14 "_" $13}else{print $1 "$local$" $2 "$" $6 "_" $5 "_" $8 "_" $7 "$-"}}else if($8=="-"){print $1 "$local$" $2 "$" $5 "_" $4 "_" $7 "_" $6 "$" $11 "_" $10 "_" $13 "_" $12}else{print $1 "$local$" $2 "$" $5 "_" $4 "_" $7 "_" $6 "$-"}}}'`



echo "  \"disk\":$disk,"
echo "  \"hostame\":$hostname,"
echo "  \"uptime_since\":$uptime_since,"
echo "  \"uptime_for\":$uptime_for,"
echo "  \"active_users\":$active_users,"
echo "  \"load_average\":$load_average_15m,"
echo "  \"users\":["
lines=`echo "$strings" | wc -l`
i=1;
for string in ${strings}; do
    IFS="$"
    set $string
    #Args="$*"
    if [ $i -eq $lines ]; then

        echo "      {\"user\":\"$1\", \"type\":\"$2\", \"from\":\"$3\", \"when\":\"`echo $4 | sed -e 's/_/ /g'`\", \"until\":\"`echo $5 | sed -e 's/_/ /g'`\"}"
    else
        echo "      {\"user\":\"$1\", \"type\":\"$2\", \"from\":\"$3\", \"when\":\"`echo $4 | sed -e 's/_/ /g'`\", \"until\":\"`echo $5 | sed -e 's/_/ /g'`\"},"
    fi
    IFS="$OIFS"

    let i=$i+1
done

echo "  ]}"

