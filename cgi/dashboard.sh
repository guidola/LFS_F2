#!/usr/bin/env bash
# IMPORTANT!! TERM env variable must be set in the shell env that calls this script

OIFS="$IFS"

cpu=`top -n 1 | head | awk 'NR == 3 {print $2 "$" $6 "$" $4 "$" $10 "$" $12 "$" $14 "$" $16 "$" $8 }'`
IFS="$"
cpu_array=($cpu)
#Args="$*"
IFS="$OIFS"

echo "Status: 200 Ok"
echo "Content-Type: application/json"
echo ""
echo ", {"
echo "  \"cpu\":["
echo "      ${cpu_array[0]},${cpu}"            #cpu_usr
echo "      ${cpu_array[1]},"            #cpu_nice
echo "      ${cpu_array[2]},"            #cpu_sys
echo "      ${cpu_array[3]},"            #cpu_iowait
echo "      ${cpu_array[4]},"            #cpu_irq
echo "      ${cpu_array[5]},"            #cpu_soft
echo "      ${cpu_array[6]},"            #cpu_steal
echo "      ${cpu_array[7]}"             #cpu-idle
echo "  ],"

mem=`free -m | awk 'NR == 2 {print $3 "$" $4 "$" $6 "$" $5 "$" $7 }'`
IFS="$"
mem_array=($mem)
#Args="$*"
IFS="$OIFS"

echo "  \"mem\":["
echo "      ${mem_array[0]},"            #mem_used
echo "      ${mem_array[1]},"            #mem_free
echo "      ${mem_array[2]},"            #mem_cache
echo "      ${mem_array[3]},"            #mem_shared
echo "      ${mem_array[4]}"             #mem_avail
echo "  ],"

disk=`df 2>/dev/null | awk '{if($6=="/") print $5 }' | sed -e 's/%//g'`

hostname=`hostname`

uptime_since=`uptime -s`
uptime_for=`uptime -p`

active_users=`uptime | awk -F "," '{print $2}'`
load_average_15m=`uptime | awk -F ',' '{print $8 "." $9}'`

strings=`last -F | head -n 10 | awk '{if($1!="reboot" && $1!="wtmp" && $0!="") if( $2 ~ /pts/ ){if($9=="-"){print $1 "$remote$" $3 "$" $6 "_" $5 "_" $8 "_" $7 "$" $12 "_" $11 "_" $14 "_" $13}else{print $1 "$remote$" $3 "$" $6 "_" $5 "_" $8 "_" $7 "$-"}}else{if( $3 ~ /:/ ) {if($9=="-"){print $1 "$local$" $2 "$$" $6 "_" $5 "_" $8 "_" $7 "$" $12 "_" $11 "_" $14 "_" $13}else{print $1 "$local$" $2 "$" $6 "_" $5 "_" $8 "_" $7 "$-"}}else if($8=="-"){print $1 "$local$" $2 "$" $5 "_" $4 "_" $7 "_" $6 "$" $11 "_" $10 "_" $13 "_" $12}else{print $1 "$local$" $2 "$" $5 "_" $4 "_" $7 "_" $6 "$-"}}}'`



echo "  \"disk\":$disk,"
echo "  \"hostname\":$hostname,"
echo "  \"uptime_since\":$uptime_since,"
echo "  \"uptime_for\":$uptime_for,"
echo "  \"active_users\":$active_users,"
echo "  \"load_average\":$load_average_15m,"
echo "  \"users\":["
lines=`echo "$strings" | wc -l`
i=1;
for string in ${strings}; do
    IFS="$"
    con=($string)
    #Args="$*"

    when=`echo ${con[3]} | sed -e 's/_/ /g'`
    until=`echo ${con[4]} | sed -e 's/_/ /g'`

    if [ $i -eq $lines ]; then
        echo "      {\"user\":\"${con[0]}\", \"type\":\"${con[1]}\", \"from\":\"${con[2]}\", \"when\":\"$when\", \"until\":\"$until\"}"
    else
        echo "      {\"user\":\"${con[0]}\", \"type\":\"${con[1]}\", \"from\":\"${con[2]}\", \"when\":\"$when\", \"until\":\"$until\"},"
    fi
    IFS="$OIFS"

    let i=i+1
done

echo "  ]}"

logger -p local0.notice "CGI dashboard: request completed"

