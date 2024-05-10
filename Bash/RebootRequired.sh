#!/bin/bash

# Check if a reboot is needed to apply updates

osLookup=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# Ubuntu or Debian reboot checking and Slack alert
if [[ "$osLookup" =~ "Ubuntu" || "$osLookup" =~ "Debian" ]]; then
	if [[ -f /var/run/reboot-required ]]; then
    	reboot
  	else
    	echo "No reboots required"
    	exit 0
  	fi

# RedHat, Amazon Linux (1, 2, 2023), and CentOS reboot checking and Slack alert
elif [[ "$osLookup" =~ "Amazon" || "$osLookup" =~ "Red" || "$osLookup" =~ "Cent" ]]; then

  	# Check if it's AL2023 since it only has dnf for package management
  	if [[ "$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release)" =~ "Amazon Linux 2023" ]]; then
    
    	# If AL2023 use dnf to check and install dnf-utils
    	dnfUtilsInstalled=$(dnf list installed dnf-utils | grep dnf-utils)
    	if [[ -n "$dnfUtilsInstalled" ]]; then
      		dnf install dnf-utils --assumeyes -q
    	else
      		echo
    	fi

  	else

    	# If not AL2023 use yum to check and install yum-utils
    	yumUtilsInstalled=$(yum list installed yum-utils | grep yum-utils)
    	if [[ -n "$yumUtilsInstalled" ]]; then
      		yum install yum-utils --assumeyes -q
    	else
      		echo
    	fi

  	fi

  	# Check if reboots are needed
  	needsReboot=$(needs-restarting -r ; echo $?)
  	if [[ "$needsReboot" =~ [1]$ ]]; then
        reboot
  	else
    	echo "No reboot required"
    	exit 0
  	fi

else
    echo "Could not determine OS, please check server manually"
fi
