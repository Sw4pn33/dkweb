#!/bin/bash

# I have written this code to check whether the user is a root user or not
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31m[!] Please run this script with sudo.\e[0m"
    exit 1
fi

echo -e "\e[0m"

echo -e "\e[1;33m[+] Setting up firewall rules: Allowing traffic on port 80... \e[0m"
ufw allow 80 > /dev/null 2>&1 || { echo -e "\e[1;31m[!] Error setting up firewall rules\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Enabling UFW firewall... \e[0m"
ufw enable && ufw reload > /dev/null 2>&1 || { echo -e "\e[1;31m[!] Error enabling or reloading the firewall rules\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Activating Tor service... \e[0m"
service tor start && service tor restart  > /dev/null 2>&1 || { echo -e "\e[1;31m[!] Error starting or restarting the Tor service\e[0m"; exit 1; }

echo -e "\n"

sleep 5 

echo -e "\e[1;33m[+] Configuring Tor Hidden Service \e[0m"
sed -i '/^DNSPort 5353$/a HiddenServiceDir /var/lib/tor/sdb/\nHiddenServiceVersion 3\nHiddenServicePort 80 127.0.0.1:80\nHiddenServiceDir /var/lib/tor/sdb_flask/\nHiddenServiceVersion 3\nHiddenServicePort 80 127.0.0.1:5000\nHiddenServiceDir /var/lib/tor/sdb_flask2/\nHiddenServiceVersion 3\nHiddenServicePort 80 127.0.0.1:5001' /etc/tor/torrc && service tor restart > /dev/null 2>&1 || { echo -e "\e[1;31m[!] Error Unable to set up hidden service\e[0m"; exit 1; }

sleep 5 

# I have written this code to setup flask with hidden service
tor_hostname=$(cat "/var/lib/tor/sdb_flask/hostname")

sed -i "87s|http://127.0.0.1:5000/search|http://$tor_hostname/search|" scrapper/templates/scrapper.html

sleep 5 

# I have written this code to setup flask2 with hidden service
tor_hostname=$(cat "/var/lib/tor/sdb_flask2/hostname")

sed -i "148s|http://127.0.0.1:5001/search|http://$tor_hostname/search|" crawler/templates/crawler.html


sed -i "166s|http://127.0.0.1:5001/keyword|http://$tor_hostname/keyword|" crawler/templates/crawler.html
