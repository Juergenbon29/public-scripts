#!/bin/bash

if [[ ! -d /opt/forticlient ]]; then 
    wget -O - https://repo.fortinet.com/repo/forticlient/7.2/debian/DEB-GPG-KEY | gpg --dearmor | sudo tee /usr/share/keyrings/repo.fortinet.com.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/repo.fortinet.com.gpg] https://repo.fortinet.com/repo/forticlient/7.2/ubuntu/ stable multiverse" > /etc/apt/sources.list.d/repo.fortinet.com.list
    apt update -y
    apt install forticlient -y
fi 
