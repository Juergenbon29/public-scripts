#!/bin/bash

###    -- Script to install SentinelOne agent on Linux, this one script works for both Ubuntu/Debian and Red Hat distros --    ###

#   -- Optional -k flag for site token if running locally --
while getopts "k:" arg
do 
    case "$arg" in 
        k) token="${OPTARG}" ;;
        *) echo "usage: [-k <SentinelOne site token>]"
           exit 1 ;;
    esac
done

if [[ "$token" == '' ]]
then
    echo -e "\nToken not set, please run again using the -k option followed by your site token\n"
    exit
fi

#   !!! -- Below this line used in Systems manager > Run command -- !!!
#   token='Insert our site token here'
if command -v sentinelctl 1>/dev/null
then
    exit
fi

osLookup=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

if [[ "$osLookup" =~ "Ubuntu" || "$osLookup" =~ "Debian" ]]
then
    cd /tmp || exit
    curl -O 'PACKAGE_URL'
    dpkg -i PACKAGE.deb
    sentinelctl management token set "$token"
    sentinelctl control start
fi

if [[ "$osLookup" =~ "Amazon" || "$osLookup" =~ "Red" || "$osLookup" =~ "Cent" ]]
then
    cd /tmp || exit
    curl -O 'PACKAGE_URL'
    rpm -i --nodigest PACKAGE.rpm
    sentinelctl management token set "$token"
    sentinelctl control start
fi