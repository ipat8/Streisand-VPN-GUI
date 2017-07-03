#!/bin/bash
notify-send --text="Streisand GUI Setup" "Give us just a second to preform basic setup." -i './gui/resources/wait.png' -t 10000 -h string:x-canonical-private-synchronous:anything
notify-send --text="Streisand GUI Setup" "We're going to request Sudo access now." -i './gui/resources/lock.png' -t 10000 -h string:x-canonical-private-synchronous:anything
SUDOPASSWORD="$( gksudo --print-pass --message 'Provide your password to allow for software installation.' -- : 2>/dev/null )"
# Check for null entry or cancellation.
if [[ ${?} != 0 || -z ${SUDOPASSWORD} ]]
then
notify-send --text="Streisand Setup" "No password Provided" -i './gui/resources/lock.png' -t 10000
exit 4
fi
# Check that the password is valid.
if ! sudo -kSp '' [ 1 ] <<<"${SUDOPASSWORD}" 2>/dev/null
then
notify-send --text="Streisand Setup" "No password Provided" -i './gui/resources/lock.png' -t 10000
exit 4
fi
sudo -Sp '' ./gui/exec/gui.sh <<<"${SUDOPASSWORD}"
