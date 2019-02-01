function isRoot () {
        if [ "$EUID" -ne 0 ]; then
                return 1
        fi
}

function createClient () {
        CLIENT=$1
        echo "Creating certificate for :"$CLIENT
        cd /etc/openvpn/easy-rsa/
        ./easyrsa build-client-full "$CLIENT" nopass

        # Home directory of the user, where the client configuration (.ovpn) will be written
        if [ -e "/home/$CLIENT" ]; then  # if $1 is a user name
                homeDir="/home/$CLIENT"
        elif [ "${SUDO_USER}" ]; then   # if not, use SUDO_USER
                homeDir="/home/${SUDO_USER}/certificates"
        else  # if not SUDO_USER, use /root
                homeDir="/root"
        fi

        # Determine if we use tls-auth or tls-crypt
        if grep -qs "^tls-crypt" /etc/openvpn/server.conf; then
                TLS_SIG="1"
        elif grep -qs "^tls-auth" /etc/openvpn/server.conf; then
                TLS_SIG="2"
        fi

        # Generates the custom client.ovpn
        cp /etc/openvpn/client-template.txt "$homeDir/$CLIENT.ovpn"
        {
                echo "<ca>"
                cat "/etc/openvpn/easy-rsa/pki/ca.crt"
                echo "</ca>"

                echo "<cert>"
                awk '/BEGIN/,/END/' "/etc/openvpn/easy-rsa/pki/issued/$CLIENT.crt"
                echo "</cert>"

                echo "<key>"
                cat "/etc/openvpn/easy-rsa/pki/private/$CLIENT.key"
                echo "</key>"

                case $TLS_SIG in
                        1)
                                echo "<tls-crypt>"
                                cat /etc/openvpn/tls-crypt.key
                                echo "</tls-crypt>"
                        ;;
                        2)
                                echo "key-direction 1"
                                echo "<tls-auth>"
                                cat /etc/openvpn/tls-auth.key
                                echo "</tls-auth>"
                        ;;
                esac
        } >> "$homeDir/$CLIENT.ovpn"

        echo ""
        echo "Client $CLIENT added, the configuration file is available at $homeDir/$CLIENT.ovpn."
        echo "Download the .ovpn file and import it in your OpenVPN client."
}

if ! isRoot; then
        echo "Sorry, you need to run this as root"
        exit 1
fi

if [ $# -lt 1 ]
then
        echo -e "${COLOR}No arguments passed. ${reset}"
        until [[ $USER_VAR =~ (y|n) ]]; do
                read -rp"Create clients from source file? [y/n]: " -e -i n USER_VAR
        done
        if [[ $USER_VAR == "y" ]];then
                for server in $(cat ~/users)
                do
                        tempusername=`echo $server|cut -d "|" -f 1`
                        username=`echo $tempusername | sed 's/\.//g'`
                        email=`echo $server|cut -d "|" -f 2`
                        echo $username $email
                        echo "*******************************************************"
                        createClient $username
                        echo -e "PFA of your ovpn files.\nPlease do not share or distribute .\nFor office use only.\nIncase of assitance contact momin.muzammil@mail.com" | s-nail -r USER -s "VPN Credentials for "`date +"%Y-%m-%d"` -a "$homeDir/$username.ovpn" $2
                done
                exit
        else
                exit
        fi
fi

if [ $# -ne 2 ]
then
        echo "Incorrect number of arguements passed."
        echo "Usage: sudo createClient username email@mail.com"
        exit
fi
createClient $1
echo -e "PFA of your ovpn files.\nPlease do not share or distribute .\nFor office use only.\nIncase of assitance contact momin.muzammil@mail.com" | s-nail -r USER -s "VPN Credentials for "`date +"%Y-%m-%d"` -a "$homeDir/$1.ovpn" $2
