#!/bin/bash

# I have written this code to check whether the user is a root user or not
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31m[!] Please run this script with sudo.\e[0m"
    exit 1
fi


echo -e "\e[33m"  

cat << "EOF"

                                                                                                                     ,--.                                                                                    
  .--.--.       ___                 ,--,         ,-.                       ,---,       ,---,       ,-.----.      ,--/  /|            ,---,.                                               ___                
 /  /    '.   ,--.'|_             ,--.'|     ,--/ /|                     .'  .' `\    '  .' \      \    /  \  ,---,': / '          ,'  .'  \                              ,---,  ,--,   ,--.'|_              
|  :  /`. /   |  | :,'            |  | :   ,--. :/ |                   ,---.'     \  /  ;    '.    ;   :    \ :   : '/ /         ,---.' .' |                  ,---,     ,---.'|,--.'|   |  | :,'             
;  |  |--`    :  : ' :            :  : '   :  : ' /                    |   |  .`\  |:  :       \   |   | .\ : |   '   ,          |   |  |: |              ,-+-. /  |    |   | :|  |,    :  : ' :  .--.--.    
|  :  ;_    .;__,'  /    ,--.--.  |  ' |   |  '  /        .--,         :   : |  '  |:  |   /\   \  .   : |: | '   |  /           :   :  :  /  ,--.--.    ,--.'|'   |    |   | |`--'_  .;__,'  /  /  /    '   
 \  \    `. |  |   |    /       \ '  | |   '  |  :      /_ ./|         |   ' '  ;  :|  :  ' ;.   : |   |  \ : |   ;  ;           :   |    ;  /       \  |   |  ,"' |  ,--.__| |,' ,'| |  |   |  |  :  /`./   
  `----.   \:__,'| :   .--.  .-. ||  | :   |  |   \  , ' , ' :         '   | ;  .  ||  |  ;/  \   \|   : .  / :   '   \          |   :     \.--.  .-. | |   | /  | | /   ,'   |'  | | :__,'| :  |  :  ;_     
  __ \  \  |  '  : |__  \__\/: . .'  : |__ '  : |. \/___/ \: |         |   | :  |  ''  :  | \  \ ,';   | |  \ |   |    '         |   |   . | \__\/: . . |   | |  | |.   '  /  ||  | :   '  : |__ \  \    `.  
 /  /`--'  /  |  | '.'| ," .--.; ||  | '.'||  | ' \ \.  \  ' |         '   : | /  ; |  |  '  '--'  |   | ;\  \'   : |.  \        '   :  '; | ," .--.; | |   | |  |/ '   ; |:  |'  : |__ |  | '.'| `----.   \ 
'--'.     /   ;  :    ;/  /  ,.  |;  :    ;'  : |--'  \  ;   :         |   | '` ,/  |  :  :        :   ' | \.'|   | '_\.'        |   |  | ; /  /  ,.  | |   | |--'  |   | '/  '|  | '.'|;  :    ;/  /`--'  / 
  `--'---'    |  ,   /;  :   .'   \  ,   / ;  |,'      \  \  ;         ;   :  .'    |  | ,'        :   : :-'  '   : |            |   :   / ;  :   .'   \|   |/      |   :    :|;  :    ;|  ,   /'--'.     /  
               ---`-' |  ,     .-./---`-'  '--'         :  \  \        |   ,.'      `--''          |   |.'    ;   |,'            |   | ,'  |  ,     .-./'---'        \   \  /  |  ,   /  ---`-'   `--'---'   
                       `--`---'                          \  ' ;        '---'                       `---'      '---'              `----'     `--`---'                  `----'    ---`-'                       
                                                          `--`                                                                                                                                               


EOF

echo -e "\e[0m"

echo -e "\n"

echo -e "\e[1;33m[+] Executing Requirements module... \e[0m"
bash requirements.sh || { echo -e "\e[1;31m[!] Error executing Requirements module.\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Executing Backbone module... \e[0m"
bash backbone.sh || { echo -e "\e[1;31m[!] Error executing Backbone module.\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Executing Scrapper module.. \e[0m"
flask_command="python3 scrapper/app.py"
log_file="logs/scrapper_server_logs.txt"

sudo -u amnesia gnome-terminal --title="Scrapper Terminal" -- bash -c "$flask_command 2>&1 | tee $log_file; exec bash" || { echo -e "\e[1;31m[!] Error executing Scrapper module.\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Executing Crawler module.. \e[0m"
flask_command="python3 crawler/app.py"
log_file="logs/crawler_server_logs.txt"

sudo -u amnesia gnome-terminal --title="Crawler Terminal" -- bash -c "$flask_command 2>&1 | tee $log_file; exec bash" || { echo -e "\e[1;31m[!] Error executing Crawler module.\e[0m"; exit 1; }

echo -e "\n"

echo -e "\e[1;33m[+] Starting PHP server \e[0m"
php_command="torify php -S 127.0.0.1:80"
log_file="logs/php_server_logs.txt"

gnome-terminal --title="PHP Server Terminal" -- bash -c "$php_command 2>&1 | tee $log_file; exec bash" || { echo -e "\e[1;31m[!] Error starting PHP server.\e[0m"; exit 1; }

echo -e "\n"

sleep 5 

# I have written this code to check whether the tor configuration is right or not
tor_hostname_file="/var/lib/tor/sdb/hostname"

if [ -f "$tor_hostname_file" ]; then
    echo "Your Tor onion service is accessible at: $(cat $tor_hostname_file)"
else
    echo "Error: Unable to retrieve Tor onion service information. Please check your configuration."
fi

echo -e "\n\e[1;32mPress Enter to exit...\e[0m"
read
