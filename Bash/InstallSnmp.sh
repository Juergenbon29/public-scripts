#!/bin/bash

###     --- Installs and configures SNMP ---

#       --- Variables ---

osLookup=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

snmpConfig=$(cat <<EOF
YOUR_CONFIG_HERE
EOF
)
#       --- Install and config SNMP ---

if [[ "$osLookup" =~ "Ubuntu" || "$osLookup" =~ "Debian" ]]; then
    if [[ ! -f /etc/snmp/snmpd.conf ]]; then
        apt install -qqy snmpd snmp libsnmp-dev
        systemctl enable snmpd
        mv /etc/snmp/snmpd.conf "/etc/snmp/snmpd.conf.bak.$(date +%F)"
        echo -e "$snmpConfig" > /etc/snmp/snmpd.conf
        systemctl restart snmpd
    else
        echo -e "\nSNMP already running, check config and manually update if necessary\n"
    fi
elif [[ "$osLookup" =~ "Amazon" || "$osLookup" =~ "Red" || "$osLookup" =~ "Cent" ]]; then
    if [[ "$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release)" =~ "Amazon Linux 2023" ]]; then
        if [[ ! -f /etc/snmp/snmpd.conf ]]; then
            dnf install -y net-snmp net-snmp-utils
            mv /etc/snmp/snmpd.conf "/etc/snmp/snmpd.conf.bak.$(date +%F)"
            echo -e "$snmpConfig" > /etc/snmp/snmpd.conf
            systemctl restart snmpd
        else
            echo -e "\nSNMP already running, check config and manually update if necessary\n"
        fi
    else
        if [[ ! -f /etc/snmp/snmpd.conf ]]; then
            yum install -y net-snmp net-snmp-utils
            mv /etc/snmp/snmpd.conf "/etc/snmp/snmpd.conf.bak.$(date +%F)"
            echo -e "$snmpConfig" > /etc/snmp/snmpd.conf
            systemctl restart snmpd
        else
            echo -e "\nSNMP already running, check config and manually update if necessary\n"
        fi
    fi
else
    echo -e "\nCannot determine OS, please manually install and configure SNMP\n"
fi