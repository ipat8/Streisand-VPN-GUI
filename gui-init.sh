#!/bin/bash
notify-send "Streisand GUI Setup" "Give us just a second to preform basic setup." -i './resources/wait.png' -t 5000
sleep 5
notify-send "Streisand GUI Setup" "We're going to request Sudo access now." -i './resources/lock.png' -t 5000
sleep 3

sudo apt-get install gksu

SUDOPASSWORD="$( gksudo --print-pass --message 'Provide your password to allow for software installation.' -- : 2>/dev/null )"
# Check for null entry or cancellation.
if [[ ${?} != 0 || -z ${SUDOPASSWORD} ]]
then
notify-send "Streisand Setup" "No password Provided. Setup stopped." -i './resources/lock.png' -t 10000
exit 4
fi
# Check that the password is valid.
if ! sudo -kSp '' [ 1 ] <<<"${SUDOPASSWORD}" 2>/dev/null
then
notify-send "Streisand Setup" "No password Provided" -i './resources/lock.png' -t 10000
exit 4
fi
sudo -Sp '' ./gui.sh <<<"${SUDOPASSWORD}"
