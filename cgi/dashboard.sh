#!/usr/bin/env bash


OIFS="$IFS"


cpu_usr=`mpstat | awk 'NR == 4 {print $3}'`
cpu_nice=`mpstat | awk 'NR == 4 {print $4}'`
cpu_sys=`mpstat | awk 'NR == 4 {print $5}'`
cpu_iowait=`mpstat | awk 'NR == 4 {print $6}'`
cpu_irq=`mpstat | awk 'NR == 4 {print $7}'`
cpu_soft=`mpstat | awk 'NR == 4 {print $8}'`
cpu_steal=`mpstat | awk 'NR == 4 {print $9}'`
cpu_guest=`mpstat | awk 'NR == 4 {print $10}'`
cpu_gnice=`mpstat | awk 'NR == 4 {print $11}'`
cpu_idle=`mpstat | awk 'NR == 4 {print $12}'`

mem_used=`free -m | awk 'NR == 2 {print $3}'`
mem_free=`free -m | awk 'NR == 2 {print $4}'`
mem_shared=`free -m | awk 'NR == 2 {print $5}'`
mem_cache=`free -m | awk 'NR == 2 {print $6}'`
mem_avail=`free -m | awk 'NR == 2 {print $7}'`

disk=`df | awk '{if($6=="/") print $5 }' | sed -e 's/%//g'`

hostname=`hostname`

uptime_since=`uptime -s`
uptime_for=`uptime -p`

active_users=`uptime | awk '{print $4}'`
load_average_15m=`uptime | awk '{print $10}'`

strings=`last -F | awk '{if($1!="reboot" && $1!="wtmp" && $0!="") if( $2 ~ /pts/ ){if($9=="-"){print $1 "$remote$" $3 "$" $6 "_" $5 "_" $8 "_" $7 "$" $12 "_" $11 "_" $14 "_" $13}else{print $1 "$remote$" $3 "$" $6 "_" $5 "_" $8 "_" $7 "$-"}}else{if( $3 ~ /:/ ) {if($9=="-"){print $1 "$local$" $2 "$$" $6 "_" $5 "_" $8 "_" $7 "$" $12 "_" $11 "_" $14 "_" $13}else{print $1 "$local$" $2 "$" $6 "_" $5 "_" $8 "_" $7 "$-"}}else if($8=="-"){print $1 "$local$" $2 "$" $5 "_" $4 "_" $7 "_" $6 "$" $11 "_" $10 "_" $13 "_" $12}else{print $1 "$local$" $2 "$" $5 "_" $4 "_" $7 "_" $6 "$-"}}}' | head -n 10`

echo "Content-Type: application/json"
echo ""
echo "{"
echo "  \"cpu\":["
echo "      $cpu_usr,"
echo "      $cpu_nice,"
echo "      $cpu_sys,"
echo "      $cpu_iowait,"
echo "      $cpu_irq,"
echo "      $cpu_soft,"
echo "      $cpu_steal,"
echo "      $cpu_guest,"
echo "      $cpu_gnice,"
echo "      $cpu_idle"
echo "  ],"
echo "  \"mem\":["
echo "      $mem_used,"
echo "      $mem_free,"
echo "      $mem_cache,"
echo "      $mem_shared,"
echo "      $mem_avail"
echo "  ],"
echo "  \"disk\":$disk,"
echo "  \"active_users\":$active_users,"
echo "  \"load_average\":$load_average_15m,"
echo "  \"users\":["
lines=`echo "$strings" | wc -l`
i=1;
for string in ${strings}; do
    IFS="$"
    set $string
    Args="$*"
    if [ $i -eq $lines ]; then

        echo "      {\"user\":\"$1\", \"type\":\"$2\", \"from\":\"$3\", \"when\":\"`echo $4 | sed -e 's/_/ /g'`\", \"until\":\"`echo $5 | sed -e 's/_/ /g'`\"}"
    else
        echo "      {\"user\":\"$1\", \"type\":\"$2\", \"from\":\"$3\", \"when\":\"`echo $4 | sed -e 's/_/ /g'`\", \"until\":\"`echo $5 | sed -e 's/_/ /g'`\"},"
    fi
    IFS="$OIFS"

    let $i=$i+1
done

echo "  ]}"

