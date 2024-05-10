#!/bin/bash

# Notified logged in user with admin privileges that they aren't allowed to be logged in, waits, then forces a logout on a MacOS system

# Get current user
currentUser=$(who | awk '/console/{print $1}')

# Get the userID
userId=$(id -u "$currentUser")

# Launch method
method="asuser"

# Check if user is an administrator
if dseditgroup -o checkmember -m "$currentUser" admin; then
    jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
	launchctl "$method" "$userId" "$jamfHelper" -windowType fs -heading "This account can't be used as a desktop user" -description "The user you have logged in as is an administrative user that should only be used to authenticate administrative requests from standard users. This account may not be used as a day-to-day user. You will be logged out. Please log in as a standard user." &
    jamfHelperPID=$!
	sleep 20
    /bin/kill $jamfHelperPID
    launchctl bootout gui/"$userId"

    # Debugging
    # echo "Would be logged out"
else
    echo "$currentUser is not an administrator, exiting"
fi