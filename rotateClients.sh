function isRoot () {
        if [ "$EUID" -ne 0 ]; then
                return 1
        fi
}

if ! isRoot; then
        echo "Sorry, you need to run this as root"
        exit 1
fi

if [ $# -lt 1 ]
then
        until [[ $USER_VAR =~ (y|n) ]]; do
                read -rp"Are you sure you want to recycle all users? [y/n]: " -e -i n USER_VAR
        done
        if [[ $USER_VAR == "y" ]];then
                for server in $(cat ~/users)
                do
                        tempusername=`echo $server|cut -d "|" -f 1`
                        username=`echo $tempusername | sed 's/\.//g'`
                        email=`echo $server|cut -d "|" -f 2`
                        echo $username $email
                        echo "*******************************************************"
                        echo "Deleting user : "$username
                        bash /home/$USER/bin/shellscript/deleteClient.sh $username
                        sleep 5s
                        echo "Creating user : "$username "with mail: "$email
                        bash /home/$USER/bin/shellscript/createClient.sh $username
                        java -jar /home/$USER/bin/jars/emailAttachments.jar /home/$USER/config/emailProps.properties $email momin.muzammil@xyz.com "VPN Credentials for "`date +"%Y-%m-%d"` "PFA of your ovpn files.Please do not share or distribute .For office use only. Incase of assitance contact momin.muzammil@xyz.com" /home/$USER/certificates/$username.ovpn
                done
        exit
        else
                echo "close call *phew*"
                exit
        fi
fi

if [ $# -ne 2 ]
then
        echo "Incorrect number of arguements passed."
        echo "Usage: sudo rotateClient username email@mail.com"
        exit
else
user=`echo $1 | sed 's/\.//g'`
echo "Deleting user : "$user
bash /home/$USER/bin/shellscript/deleteClient.sh $user
sleep 5s
echo "Creating user : "$user "with mail: "$2
bash /home/$USER/bin/shellscript/createClient.sh $user $2
fi
