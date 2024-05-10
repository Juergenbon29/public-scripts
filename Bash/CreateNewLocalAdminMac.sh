#!/bin/bash

### --- Add local admin account for users who have admin privileges on their daily driver accounts. Provides a pop-up window for user to enter new admin password and won't go away until they input a valid password ---

# Get current user
currentUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
userId=$(id -u "$currentUser")
method="asuser"

# Checks if user is member of admin group
isAdmin=$(dseditgroup -o checkmember -m "$currentUser" admin | awk '{print $1}')

#   --- Redundancy checks ---

# Check if signed in user is a built in account
if [[ "$currentUser" == "REDACTED" || "$currentUser" == "REDACTED" || "$currentUser" == "REDACTED" || "$currentUser" == "REDACTED" ]]; then
    echo "The policy/changes do not apply to $currentUser, exiting"
    exit 0
fi

# Checks if signed in user has admin privileges
if [[ "$isAdmin" == "no" ]]; then
    echo "$currentUser is not and admin and this device does not need to be reconfigured, exiting"
    exit 0
elif [[ "$currentUser" =~ [a-zA-Z]+\.[a-zA-Z]+\.admin ]]; then
    launchctl bootout gui/"$userId"
    echo "$currentUser tried to log in with their admin account!"
    exit 0
fi

# Sets admin account name and checks if it exists
adminUser="$currentUser.admin"
id -u "$adminUser">/dev/null

if [[ $? == 1 ]]; then
    echo "$currentUser does not have an admin account, continuing to create it"
    # Show warning dialog of upcoming changes
    launchctl "$method" "$userId" /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "Account changes pending" -description "In an effort to increase security on your workstation $currentUser will no longer be able to perform administrative tasks. A new accout will be created that you should use to perform administrative tasks in the future. This new account is: $adminUser. You will now be prompted to set the password for this account" -button1 "OK" -defaultButton 1 -lockHUD
else
    echo "$currentUser already has an admin account, or another error is present. Last exit code: $?"
    exit 1
fi

# ---   Functions   ---

# Password dummy variables
password="password"
passwordVerify="not password"

# Prompt user to enter and confirm password and stores in variable
setPassword () {
    password=$(launchctl "$method" "$userId" osascript <<EOD
    tell application id "com.apple.systemuiserver"
    end tell
    display dialog "If you are seeing this it is because you need to set a new password for your local admin account.\n\nPlease enter a password containing at least:\n15 characters\n1 upper case\n1 lower case\n1 number\n1 special character\n\nIt is recommended that you save this password in your private vault" with hidden answer default answer ""
    return text returned of result
EOD
)
    passwordVerify=$(launchctl "$method" "$userId" osascript <<EOD
    tell application id "com.apple.systemuiserver"
    end tell
    display dialog "Please verify the password" with hidden answer default answer ""
    return text returned of result
EOD
)
}

# Check if passwords match
verifyMatch () {
    if [[ "$password" == "$passwordVerify" ]]; then
        match=1
    else
        match=0
    fi
}

# Verify password contains at least: 1x lower, 1x upper, 1x number, 1x special, 15 characters
complexity () {
    if [[ $password =~ [a-z]+ ]]; then
        lower=1
    else
        lower=0
    fi

    if [[ $password =~ [A-Z]+ ]]; then
        upper=1
    else
        upper=0
    fi

    if [[ $password =~ [0-9]+ ]]; then
        number=1
    else
        number=0
    fi

    if [[ $password =~ (.*[!@\#\-$=+_%^&*()\\\|{};:\'\",<.>/?\`~]).* ]]; then
        symbol=1
    else
        symbol=0
    fi

    lengthInt=${#password}
    if [[ $lengthInt -gt 14 ]]; then
        length=1
        #echo $lengthInt
    else
        length=0
        #echo $lengthInt
    fi

    # Adds results of each complexity check
    complex=$((lower + upper + number + symbol + length))
}

#   --- Processing of account creation ---
# Initialize passCheck variable
passCheck=0
# Prompt user to enter and verify password then check validity. Keep prompting if passwords don't match or meet complexity requirements
while [[ $passCheck != 6 ]]; do
    loggedInUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
    if [[ "$currentUser" = "$loggedInUser" ]]; then
        setPassword
        verifyMatch
        complexity
        passCheck=$((complex + match))
        # Debugging
        #echo "$complex - complexity total"
        #echo "$match - matching passwords"
        #echo "$passCheck - total of complexity + match"
        #echo "$password - password"
        #echo "$passwordVerify - passwordVerify"
    else
        echo "Current user does not match logged in user, exiting"
        exit 2
    fi
done
# Removes user from admin group if they are in it
if [[ $isAdmin == "yes" ]]; then
    dseditgroup -o edit -d "$currentUser" -t user admin
    echo "$currentUser removed from admin group"
    # Debugging
    #echo "$currentUser is a member of the admin group - return value of isAdmin: $isAdmin"
else
    echo "$currentUser is not a member of the admin group"
    # Debugging
    #echo "return value of isAdmin: $isAdmin"
fi
# Create user and set necessary properties
adminPath="/Users/$adminUser"
uniqueId=$((userId + 5))
dscl . -create "$adminPath"
dscl . -create "$adminPath" RealName "$adminUser"
dscl . -create "$adminPath" PrimaryGroupID 20
dscl . -create "$adminPath" UserShell /bin/zsh # Can change to /bin/bash if needed
dscl . -create "$adminPath" UniqueID "$uniqueId"
dscl . -passwd "$adminPath" "$password" # Set password
dscl . -create "$adminPath" NFSHomeDirectory /Users/"$adminUser"
dscl . create "$adminPath" IsHidden 1
chflags hidden "$adminPath"
dseditgroup -o edit -t user -a "$adminUser" admin # Add admin user to admin group
# Create file for Jamf extension attribute
touch REDACTED
/usr/local/bin/jamf recon
# Alert user of changes and reboot and give them a choice to reboot now or wait 10 minutes
reboot=$(launchctl "$method" "$userId" /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "Pending reboot" -description "$adminUser has been created! The user $currentUser will no longer be able to perform administrative tasks. Your computer needs to be rebooted to apply this change. Your computer will be rebooted in 5 minutes, or you can reboot now." -button1 "Reboot Now" -button2 "Wait" -defaultButton 1 -lockHUD)
if [[ "$reboot" == "0" ]]; then
    reboot now
    # Debugging
    #echo "Reboot"
else
    sleep 300
    reboot now
    # Debugging
    #sleep 5
    #echo "I waited 5 seconds"
fi