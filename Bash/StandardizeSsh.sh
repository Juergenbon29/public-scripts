#!/bin/bash

osVersion=$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release)

# Public keys
user1key="PUB_KEY"
user2key="PUB_KEY"
user3key="PUB_KEY"
user4key="PUB_KEY"
user5key="PUB_KEY"

# Fuctions
function replaceSshd {
    echo "$sshdConfig" > sshd_config.temp
    if diff -q sshd_config.temp /etc/ssh/sshd_config; then
        echo "No difference from standard config detected"
        rm sshd_config.temp
        echo "Done!"
    else
        echo "sshd_config not set to standard, fixing..."
        cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%F)"
        mv sshd_config.temp /etc/ssh/sshd_config
        systemctl restart sshd || service sshd restart
        echo "Done!"
    fi 
}

function createHomeDir {
            # Create home directory if not present
            if [[ ! -d $homeDir ]]; then 
                echo "No home directory, creating now..."
                mkdir "$homeDir"
                echo "Home directory created for $u"
            fi 
            # Create authorized_keys file if not present
            if [[ ! -f "$homeDir/.ssh/authorized_keys" ]]; then 
                echo "authorized_keys file does not exist, creating..."
                if [[ ! -d "$homeDir/.ssh" ]]; then 
                    mkdir "$homeDir/.ssh"
                    echo ".ssh directory created for $u"
                fi 
                touch "$homeDir/.ssh/authorized_keys"
                chown -R "$u:$u" "$homeDir"
                chmod 700 "$homeDir/.ssh"
                chmod 400 "$homeDir/.ssh/authorized_keys"
                echo "authorized_keys file created for $u"
            fi
}

function createBackupUsers {
    for u in "${users[@]}"; do
        homeDir="/home/$u"
        if id -u "$u" >/dev/null 2>&1; then 
            echo "$u exists, checking for home directory and authorized_keys file..."
            createHomeDir
        else
            echo "$u does not exist, creating now..."
            useradd -m "$u" -s /bin/bash
            createHomeDir
        fi
        # Add appropriate key to user's authorized_keys file
        case $u in
            user1)
                if grep -q "$user1key" "$homeDir/.ssh/authorized_keys"; then 
                    echo "$u's key is already present, skipping"
                else 
                    echo "$user1key" >> "$homeDir/.ssh/authorized_keys"
                    echo "Added $u's key to authorized_keys"
                fi
                ;;
            user2)
                if grep -q "$user2key" "$homeDir/.ssh/authorized_keys"; then 
                    echo "$u's key is already present, skipping"
                else 
                    echo "$user2key" >> "$homeDir/.ssh/authorized_keys"
                    echo "Added $u's key to authorized_keys"
                fi
                ;;
            user3)
                if grep -q "$user3key" "$homeDir/.ssh/authorized_keys"; then 
                    echo "$u's key is already present, skipping"
                else 
                    echo "$user3key" >> "$homeDir/.ssh/authorized_keys"
                    echo "Added $u's key to authorized_keys"
                fi
                ;;
            user4)
                if grep -q "$user4key" "$homeDir/.ssh/authorized_keys"; then 
                    echo "$u's key is already present, skipping"
                else 
                    echo "$user4key" >> "$homeDir/.ssh/authorized_keys"
                    echo "Added $u's key to authorized_keys"
                fi
                ;;
            user5)
                if grep -q "$user5key" "$homeDir/.ssh/authorized_keys"; then 
                    echo "$u's key is already present, skipping"
                else 
                    echo "$user5key" >> "$homeDir/.ssh/authorized_keys"
                    echo "Added $u's key to authorized_keys"
                fi
                ;;
            *)
                echo "$u does not have a key set in this script"
                ;;
        esac
    done
}

# Check if the server belongs to XXXX and assign sshd_config variable and backup SSH user list accordingly
if id "SPECIFIC_USER" &>/dev/null && grep -q "Ubuntu" /etc/os-release; then
    echo "Detected SPECIFIC server running Ubuntu, using appropriate config"
    sshdConfig=$(cat <<EOF
### COMPANY standardized ###
YOUR_CONFIG_HERE
EOF
)
    users=(
        USER_LIST
    )
elif [[ $osVersion =~ "Ubuntu" ]]; then 
    echo "Detected Ubuntu server"
    sshdConfig=$(cat <<EOF
### COMPANY standardized ###
YOUR_CONFIG_HERE
EOF
)
    users=(
        USER_LIST
    )
elif [[ $osVersion =~ "Debian" ]]; then 
    echo "Detected Debian server"
    sshdConfig=$(cat <<EOF
### COMPANY standardized ###
YOUR_CONFIG_HERE
EOF
)
    users=(
        USER_LIST
    )
else 
    echo "Did not detect XXXX, XXXX, or Ubuntu server"
    sshdConfig=$(cat <<EOF
YOUR_CONFIG_HERE
EOF
)
    users=(
        USER_LIST
    )
fi

createBackupUsers
replaceSshd