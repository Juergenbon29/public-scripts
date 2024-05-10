#!/bin/bash
disableRedir=(
    CUSTOM_OPTIONS
)

cp /etc/sysctl.conf "/etc/sysctl.conf.bak.$(date +%F)"

for d in "${disableRedir[@]}"; do 
    if grep -q "$d.*1" /etc/sysctl.conf; then 
        echo "$d is enabled, disabling"
        sed -i "s/$d.*1/$d=0/g" /etc/sysctl.conf
        echo "$d has been disabled"
    elif grep -q "$d"0 /etc/sysctl.conf; then 
        echo "Bad entry, $d, found in sysctl.conf, fixing"
        sed -i "s/$d\0/$d=0/g" /etc/sysctl.conf
        echo "Fixed!"
    fi 
done

sysctl -p