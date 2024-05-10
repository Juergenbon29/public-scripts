#!/usr/bin/env bash
# Script designed to be ran locally that imports a user's ssh key

# Prompt for variables
echo "Enter username:"
read -r username
echo "The user you will be creating is: $username"

echo "Please enter $username's public SSH key:"
read -r userpubkey
echo "$username's public SSH key has been entered."

# Check if user exists
if id -u "$username" >/dev/null; then
    echo "This user already exists."
else
    echo "User does not exist, $username will be created."
    useradd -m "$username" -s /bin/bash
fi

# Check for .ssh directory and authorized_keys file
if [[ -f "/home/$username/.ssh/authorized_keys" ]]; then 
    echo "$username SSH Authorized Keys file exists."
else 
    echo "$username SSH Authorized Keys file does not exist, one will be created."
    if [[ -d "/home/$username/.ssh/" ]]; then                   #checking for .ssh directory
        echo ".ssh directory exists."
    else 
        echo ".ssh directory does not exist, directory will be created now."
        mkdir -p "/home/$username/.ssh"                         #creates .ssh directory
    fi
    touch "/home/$username/.ssh/authorized_keys"                #creates authorized keys file
fi

chown -R "$username":"$username" "/home/$username/.ssh/"        #changes ownership of directory to username variable

if grep -q "$userpubkey" "/home/$username/.ssh/authorized_keys"; then #searches authorized keys file for userpubkey
    echo "Key exists."
else
    echo "Key not found, adding now..."
    echo "$userpubkey" >> "/home/$username/.ssh/authorized_keys"
fi

chmod 700 "/home/$username/.ssh/"                       #making directory r/w/x for user
chmod 400 "/home/$username/.ssh/authorized_keys"        #making file read only for user

# End Step 2.

if [[ -f /etc/ssh/sshd_config ]]; then                  #checking to see if file exists
    cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak.$(date +%F)"        #copy config file to .bak backup file w/ date attached in case of errors
    if grep -q "$username" "/etc/ssh/sshd_config"; then                     #checking to see if username is already in sshd_config file
        echo "$username already in sshd_config"
    else
        echo "Adding user to sshd_config..."
        sed -i "/AllowUser/s/$/ ${username}/" "/etc/ssh/sshd_config"
        if sshd -T >> /dev/null; then
            systemctl restart sshd
        else 
            echo "Config file has errors, restoring from backup..."
            cp "/etc/ssh/sshd_config.bak.$(date +%F)" "/etc/ssh/sshd_config"
        fi
    fi
fi 