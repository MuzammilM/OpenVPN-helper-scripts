# OpenVPN-helper-scripts
https://github.com/angristan/openvpn-install


## Install createVPNClient via curl
    mkdir -p ~/bin/shellscript && curl -s https://raw.githubusercontent.com/MuzammilM/OpenVPN-helper-scripts/master/createClient.sh -o ~/bin/shellscript/createClient.sh && sudo ln -s /home/$USER/bin/shellscript/createClient.sh /usr/bin/createVPNClient && sudo chmod +x /usr/bin/createVPNClient
 
 ## Install deleteVPNClient via curl
    mkdir -p ~/bin/shellscript && curl -s https://raw.githubusercontent.com/MuzammilM/OpenVPN-helper-scripts/master/deleteClient.sh -o ~/bin/shellscript/deleteClient.sh && sudo ln -s /home/$USER/bin/shellscript/deleteClient.sh /usr/bin/deleteVPNClient && sudo chmod +x /usr/bin/deleteVPNClient
 
## Install rotateVPNClient via curl
     mkdir -p ~/bin/shellscript && curl -s https://raw.githubusercontent.com/MuzammilM/OpenVPN-helper-scripts/master/rotateClients.sh -o ~/bin/shellscript/rotateClients.sh && sudo ln -s /home/$USER/bin/shellscript/rotateClients.sh /usr/bin/rotateVPNClients && sudo chmod +x /usr/bin/rotateVPNClients
