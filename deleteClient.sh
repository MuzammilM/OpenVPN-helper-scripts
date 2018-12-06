COLOR='\033[0;31m'
reset=`tput sgr0`

function isRoot () {
        if [ "$EUID" -ne 0 ]; then
                return 1
        fi
}

function revokeClient () {
        NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
        if [ $# -lt 1 ]
        then
                echo "Select the existing client certificate you want to revoke"
                tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
                if [[ "$NUMBEROFCLIENTS" = '1' ]]; then
                        read -rp "Select one client [1]: " CLIENTNUMBER
                else
                        read -rp "Select one client [1-$NUMBEROFCLIENTS]: " CLIENTNUMBER
                fi

        CLIENT=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$CLIENTNUMBER"p)
        else
        CLIENT=$1
        fi
        echo "Deleting certificate for : "$CLIENT
        cd /etc/openvpn/easy-rsa/
        ./easyrsa --batch revoke "$CLIENT"
        EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
        # Cleanup
        rm -f "pki/reqs/$CLIENT.req"
        rm -f "pki/private/$CLIENT.key"
        rm -f "pki/issued/$CLIENT.crt"
        rm -f /etc/openvpn/crl.pem
        cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
        chmod 644 /etc/openvpn/crl.pem
        find /home/ -maxdepth 2 -name "$CLIENT.ovpn" -delete
        rm -f "/root/$CLIENT.ovpn"
        sed -i "s|^$CLIENT,.*||" /etc/openvpn/ipp.txt

        echo ""
        echo "Certificate for client $CLIENT revoked."



}

if ! isRoot; then
        echo "Sorry, you need to run this as root"
        exit 1
fi

if [ $# -lt 1 ]
then
        echo -e "${COLOR}No arguments passed. ${reset}"
        revokeClient
        exit
fi
NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
if [[ "$NUMBEROFCLIENTS" = '0' ]]; then
        echo "You have no existing clients!"
exit 1
fi
revokeClient $1
