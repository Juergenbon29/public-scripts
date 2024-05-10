#!/bin/bash

# Create dev users and add them to custom sudoers file

devs=(
    "USER_LIST_HERE"
)

sudoFile="/etc/sudoers.d/CUSTOM_SUDOERS_FILE"

# Check for CUSTOM_SUDOERS_FILE sudoers file and create if not present
if [[ -f $sudoFile ]]; then 
    cp $sudoFile "$sudoFile.bak.$(date +%F)"
else 
    touch $sudoFile
fi

for d in "${devs[@]}"; do
    # Check for existing account and create it if not present
    if ! id -u "$d" >/dev/null; then 
        useradd -m "$d" -s /bin/bash
        echo "$d has been created"
    fi 

    # Check for user's entry in sudoers file and add if not present
    if ! grep -q "$d" $sudoFile; then
        echo "$d CUSTOM=SUDO: OPTIONS" >> $sudoFile
        echo "$d added to $sudoFile"
    fi 
done
