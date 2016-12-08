#!/usr/bin/env bash

show=0
modify=1
insert=0
delete=1
xcorrect=0
xerror=1
esyntax=2
ecode=3
OIFS="$IFS"

while true
do
    IFS="$" read codi pid table action num chain prot iint oint source dest spt dpt to target <$1
    IFS="$OIFS"
    [[ ${codi} == "2" ]] || exit 0
    [[ ! -z ${codi} || ! -z ${pid} || ${pid} == *"$"* ]] || echo "${esyntax}" >> "${1}${pid}"; continue

    case ${codi} in
        ${show})
            missatge='{"filter":{"forward":['
            strings=`sudo iptables -L FORWARD --line-numbers -v -n | awk 'NR>2{match($0, /dpts?:[:0-9]+/, arr); match($0, /spts?:[:0-9]+/, ar); print $1 "$" $2 "$" $4 "$" $5 "$" $7 "$" $8 "$" $9 "$" $10 "$" ar[0] "$" arr[0]}'`

            for string in ${strings}; do
                IFS="$" read -ra params <<< "$string"
                missatge="${missatge}{\"num\":${params[0]},\"pkts\":${params[1]},\"target\":${params[2]},\"prot\":${params[3]},\"in\":${params[4]},\"out\":${params[5]},\"source\":${params[6]},\"destination\":${params[7]},\"spt\":${params[8]},\"dpt\":${params[9]}},"
            done
            IFS="$OIFS"
            if [[ ! -z $strings ]]; then
                missatge="${missatge%?}], \"input\":["
            else
               missatge="${missatge}], \"input\":["
            fi
            strings=`sudo iptables -L INPUT --line-numbers -v -n | awk 'NR>2{match($0, /dpts?:[:0-9]+/, arr); match($0, /spts?:[:0-9]+/, ar); print $1 "$" $2 "$" $4 "$" $5 "$" $7 "$" $8 "$" $9 "$" $10 "$" ar[0] "$" arr[0]}'`
            for string in ${strings}; do
                IFS="$" read -ra params <<< "$string"
                missatge="${missatge}{\"num\":${params[0]},\"pkts\":${params[1]},\"target\":${params[2]},\"prot\":${params[3]},\"in\":${params[4]},\"out\":${params[5]},\"source\":${params[6]},\"destination\":${params[7]},\"spt\":${params[8]},\"dpt\":${params[9]}},"
            done
            IFS="$OIFS"
            if [[ ! -z $strings ]]; then
                missatge="${missatge%?}], \"output\":["
            else
               missatge="${missatge}], \"outpt\":["
            fi
            strings=`sudo iptables -L OUTPUT --line-numbers -v -n | awk 'NR>2{match($0, /dpts?:[:0-9]+/, arr); match($0, /spts?:[:0-9]+/, ar); print $1 "$" $2 "$" $4 "$" $5 "$" $7 "$" $8 "$" $9 "$" $10 "$" ar[0] "$" arr[0]}'`
            for string in ${strings}; do
                IFS="$" read -ra params <<< "$string"
                missatge="${missatge}{\"num\":${params[0]},\"pkts\":${params[1]},\"target\":${params[2]},\"prot\":${params[3]},\"in\":${params[4]},\"out\":${params[5]},\"source\":${params[6]},\"destination\":${params[7]},\"spt\":${params[8]},\"dpt\":${params[9]}},"
            done
            IFS="$OIFS"
            if [[ ! -z $strings ]]; then
                missatge="${missatge%?}]}, \"nat\":{\"prerouting\":["
            else
                missatge="${missatge}]}, \"nat\":{\"prerouting\":["
            fi
            strings=`sudo iptables -L PREROUTING -t nat --line-numbers -v -n | awk 'NR>2{match($0, /dpts?:[:0-9]+/, arr); match($0, /spts?:[:0-9]+/, ar); match($0, /to:[:\.0-9]+/, arra); print $1 "$" $2 "$" $4 "$" $5 "$" $7 "$" $8 "$" $9 "$" $10 "$" ar[0] "$" arr[0] "$" arra[0]}'`
            for string in ${strings}; do
                IFS="$" read -ra params <<< "$string"
                missatge="${missatge}{\"num\":${params[0]},\"pkts\":${params[1]},\"target\":${params[2]},\"prot\":${params[3]},\"in\":${params[4]},\"out\":${params[5]},\"source\":${params[6]},\"destination\":${params[7]},\"spt\":${params[8]},\"dpt\":${params[9]},\"to\":${params[10]}},"
            done
            IFS="$OIFS"
            if [[ ! -z $strings ]]; then
                missatge="${missatge%?}], \"postrouting\":["
            else
               missatge="${missatge}], \"postrouting\":["
            fi
            strings=`sudo iptables -L POSTROUTING -t nat --line-numbers -v -n | awk 'NR>2{match($0, /dpts?:[:0-9]+/, arr); match($0, /spts?:[:0-9]+/, ar); match($0, /to:[:\.0-9]+/, arra); print $1 "$" $2 "$" $4 "$" $5 "$" $7 "$" $8 "$" $9 "$" $10 "$" ar[0] "$" arr[0] "$" arra[0]}'`
            for string in ${strings}; do
                IFS="$" read -ra params <<< "$string"
                missatge="${missatge}{\"num\":${params[0]},\"pkts\":${params[1]},\"target\":${params[2]},\"prot\":${params[3]},\"in\":${params[4]},\"out\":${params[5]},\"source\":${params[6]},\"destination\":${params[7]},\"spt\":${params[8]},\"dpt\":${params[9]},\"to\":${params[10]}},"
            done
            IFS="$OIFS"
            if [[ ! -z $strings ]]; then
                missatge="${missatge%?}], \"input\":["
            else
               missatge="${missatge}], \"input\":["
            fi
            strings=`sudo iptables -L INPUT -t nat --line-numbers -v -n | awk 'NR>2{match($0, /dpts?:[:0-9]+/, arr); match($0, /spts?:[:0-9]+/, ar); match($0, /to:[:\.0-9]+/, arra); print $1 "$" $2 "$" $4 "$" $5 "$" $7 "$" $8 "$" $9 "$" $10 "$" ar[0] "$" arr[0] "$" arra[0]}'`
            for string in ${strings}; do
                IFS="$" read -ra params <<< "$string"
                missatge="${missatge}{\"num\":${params[0]},\"pkts\":${params[1]},\"target\":${params[2]},\"prot\":${params[3]},\"in\":${params[4]},\"out\":${params[5]},\"source\":${params[6]},\"destination\":${params[7]},\"spt\":${params[8]},\"dpt\":${params[9]},\"to\":${params[10]}},"
            done
            IFS="$OIFS"
            if [[ ! -z $strings ]]; then
                missatge="${missatge%?}], \"output\":["
            else
               missatge="${missatge}], \"output\":["
            fi
            strings=`sudo iptables -L OUTPUT -t nat --line-numbers -v -n | awk 'NR>2{match($0, /dpts?:[:0-9]+/, arr); match($0, /spts?:[:0-9]+/, ar); match($0, /to:[:\.0-9]+/, arra); print $1 "$" $2 "$" $4 "$" $5 "$" $7 "$" $8 "$" $9 "$" $10 "$" ar[0] "$" arr[0] "$" arra[0]}'`
            for string in ${strings}; do
                IFS="$" read -ra params <<< "$string"
                missatge="${missatge}{\"num\":${params[0]},\"pkts\":${params[1]},\"target\":${params[2]},\"prot\":${params[3]},\"in\":${params[4]},\"out\":${params[5]},\"source\":${params[6]},\"destination\":${params[7]},\"spt\":${params[8]},\"dpt\":${params[9]},\"to\":${params[10]}},"
            done
            IFS="$OIFS"
            if [[ ! -z $strings ]]; then
                missatge="${missatge%?}]}}"
            else
                missatge="${missatge}]}}"
            fi
            echo "${xcorrect}" >> "${1}${pid}"
            echo "${missatge}" >> "${1}${pid}";;

        ${modify})

            missatge='iptables '
            [[ -z ${table} ]] || missatge="${missatge}-t ${table}"
            [[ ! -z ${action} || ! -z ${num} || ! -z ${chain} ]] || echo "${esyntax}" >> "${1}${pid}"; continue
            if [[ ${action} -eq ${delete} ]]; then
                 missatge="${missatge}-D ${chain} ${num}"
                 ${missatge}
                 if [ $? -eq 0 ]
                    then echo "${xcorrect}" >> "${1}${pid}"
                    else echo "${xerror}" >> "${1}${pid}"
                 fi
            else if [[ ${action} -eq ${insert} ]]; then
                     missatge="${missatge}-I ${chain}${num} "
                     [[ -z ${prot} ]] || missatge="${missatge} -p ${prot}"
                     [[ -z ${iint} ]] || missatge="${missatge} -i ${iint}"
                     [[ -z ${oint} ]] || missatge="${missatge} -o ${oint}"
                     [[ -z ${source} ]] || missatge="${missatge} -s ${source}"
                     [[ -z ${dest} ]] || missatge="${missatge} -d ${dest}"
                     [[ -z ${spt} ]] || missatge="${missatge} --sport ${spt}"
                     [[ -z ${dpt} ]] || missatge="${missatge} --dport ${dpt}"
                     [[ -z ${to} ]] || missatge="${missatge} --to ${to}"
                     [[ -z ${target} ]] || missatge="${missatge} -j ${target}"
                     ${missatge}
                     if [ $? -eq 0 ]
                        then echo "${xcorrect}" >> "${1}${pid}"
                        else echo "${xerror}" >> "${1}${pid}"
                     fi
                 else
                     echo "${esyntax}" >> "${1}${pid}"
                 fi
            fi;;
        *)  echo "${ecode}" >> "${1}${pid}";;
    esac
done