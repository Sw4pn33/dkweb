#!/bin/bash

# I have written this code to check whether the user is a root user or not
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31m[!] Please run this script with sudo.\e[0m"
    exit 1
fi

echo -e "\e[1;33m[+] Updating system. Please wait... \e[0m"
apt update > /dev/null 2>&1 || { echo -e "\e[1;31m[!] Error updating system\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Installing required packages \e[0m"
apt install -y ufw php > /dev/null 2>&1 || { echo -e "\e[1;31m[!] Error installing packages\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Installing required libraries \e[0m"

# I have written this code to Retry library installation up to 3 times
for attempt in {1..3}; do
    apt install -y python3-pip python3-pandas python3-flask-cors > /dev/null 2>&1 && break
    echo -e "\e[1;31m[!] Error installing libraries. Retrying... (Attempt $attempt)\e[0m"
    sleep 5
done

if [ $? -ne 0 ]; then
    echo -e "\e[1;31m[!] Failed to install libraries after multiple attempts. Exiting.\e[0m"
    exit 1
fi

echo -e "\n"

echo -e "\e[1;33m[+] All requirements have been successfully installed. You can now use the tool. \e[0m"
