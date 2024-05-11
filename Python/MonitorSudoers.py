#!/usr/bin/env python3

# Monitors sudoers file on MacOS
import time
import requests
import hashlib
import os
import sys
import daemon
import subprocess

# Define the Slack webhook URL
slack_webhook_url = "WEBHOOK_URL"

# Get the initial hash of the sudoers file
initial_hash = hashlib.sha256(open("/etc/sudoers", "rb").read()).hexdigest()

def send_alert(loggedInUser, user, hostname):
    # Construct the alert message in Slack format
    alert_data = {
        "attachments": [
            {
                "color": "danger",
                "text": f"Changes detected in `/etc/sudoers` file\nLogged in user: {loggedInUser}\nUser: {user}\nHostname: {hostname}"
            }
        ]
    }

    try:
        response = requests.post(slack_webhook_url, json=alert_data)
        if response.status_code == 200:
            print("Alert sent successfully")
        else:
            print("Failed to send alert. Status code:", response.status_code)
    except Exception as e:
        print("An error occurred while sending alert:", e)

def run_as_background_service():
    global initial_hash  # Declare initial_hash as global
    while True:
        current_hash = hashlib.sha256(open("/etc/sudoers", "rb").read()).hexdigest()
        if current_hash != initial_hash:
            print("Changes detected in /etc/sudoers. Sending alert...")
            loggedInUser = subprocess.getoutput('echo "show State:/Users/ConsoleUser" | scutil | awk \'/Name :/ {print $3}\'')
            user = os.getlogin()
            hostname = os.uname().nodename
            send_alert(loggedInUser, user, hostname)
            # Update the initial hash to the current hash
            initial_hash = current_hash
        time.sleep(1)

def main():  # Commented out for running in foreground
    with daemon.DaemonContext():  # Commented out for running in foreground
        run_as_background_service()  # Commented out for running in foreground

if __name__ == "__main__":
    main()  # Commented out for running in foreground
    # run_as_background_service()  # Run in the foreground for testing