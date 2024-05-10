#!/bin/bash

# Check if a reboot is needed to apply updates

osLookup=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
slack_webhook_url="WEBHOOK_URL_HERE"

# Ubuntu or Debian reboot checking and Slack alert
if [[ "$osLookup" =~ "Ubuntu" || "$osLookup" =~ "Debian" ]]; then
	
	if [[ -f /var/run/reboot-required ]]; then
    	update_details=$(cat /var/run/reboot-required.pkgs)
    	message=$(cat <<EOF
{
  	"attachments": [
    	{
      		"fallback": "Reboot is needed to apply the following updates on $(hostname):",
      		"color": "warning",
      		"title": "Reboot is needed to apply the following updates on $(hostname):",
      		"text": "$update_details",
      		"footer": "This alert has been brought to you by your friendly IT team"
    	}
  	]
}
EOF
)
    	curl -X POST -H 'Content-type: application/json' --data "$message" "$slack_webhook_url"

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

    	update_details=$(needs-restarting -r)
    	message=$(cat <<EOF
{
  	"attachments": [
    	{
      		"fallback": "Reboot is needed to apply the following updates on $(hostname):",
      		"color": "warning",
      		"title": "Reboot is needed to apply the following updates on $(hostname):",
      		"text": "$update_details",
      		"footer": "This alert has been brought to you by your friendly IT team"
    	}
  	]
}
EOF
)
    	curl -X POST -H 'Content-type: application/json' --data "$message" "$slack_webhook_url"

  	else
    	echo "No reboot required"
    	exit 0
  	fi

else

  	message=$(cat <<EOF
{
  	"attachments": [
    	{
      		"fallback": "Cannot determine OS on $(hostname).",
      		"color": "alert",
      		"title": "Cannot determine OS on $(hostname).",
      		"text": "",
      		"footer": "This alert has been brought to you by your friendly IT team"
    	}
  	]
}
EOF
)
  	curl -X POST -H 'Content-type: application/json' --data "$message" "$slack_webhook_url"

fi
