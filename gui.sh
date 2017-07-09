sudo apt-get update
sudo apt-get install zenity wmctrl
notify-send "Basic package install complete, we'll now begin the Streisand install process."
sleep 2
#Force Zenity to be on top.
sleep 1 && wmctrl -a AWS -b add,above&
#Start progress box
(coproc zenity --progress --pulsate --width=450 \
  --title="AWS Streisand Server Deployment Status" \
  --text="First Task." \
  --percentage=0)

##  >&${COPROC[1]}
# =================================================================
echo "# Checking system for mobile platform compatibility." >&${COPROC[1]} ; sleep 1
sudo ssh-keygen
if ping -c 1 8.8.8.8
  then
    zenity --info --name="AWS Streisand Server Setup" --class="AWS Streisand Server Setup" --name="AWS Streisand Server Setup" --window-icon="error" --icon-name="process-stop" --title="Network test failure" --title="Network test failure" --text="Please connect to the internet and try again. Exiting."
    exit
  else
    zenity --info --name="AWS Streisand Server Setup" --class="AWS Streisand Server Setup" --name="AWS Streisand Server Setup" --window-icon="info" --icon-name="emblem-default" --title="Network test successful" --title="Network test successful" --text="Continueing Setup."
fi
# =================================================================
echo "5" >&${COPROC[1]}
echo "# Preparing system for mobile deployment." >&${COPROC[1]} ; sleep 1
sudo apt-get dist-upgrade
sudo apt-get install git
# =================================================================
echo "15" >&${COPROC[1]}
echo "# Downloading preinstall software." >&${COPROC[1]} ; sleep 1
sudo apt-get install python-paramiko python-pip python-pycurl python-dev build-essential
sudo pip install ansible markupsafe
sudo pip install boto
sudo pip install msrest msrestazure azure==2.0.0rc5
sudo pip install dopy==0.3.5
sudo pip install apache-libcloud>=1.5.0
sudo pip install linode-python
sudo pip install pyrax
# =================================================================
echo "40" >&${COPROC[1]}
echo "# Downloading required modules." >&${COPROC[1]} ; sleep 1
# git clone https://github.com/jlund/streisand.git vpnexec
# git clone $repo when I get to it
# =================================================================
echo "50" >&${COPROC[1]}
echo "# Prepairing to switch to striesand. Requesting user information." >&${COPROC[1]} ; sleep 1
provider=$(zenity  --list --title="Select Provider" --text "What provider are you using?" --radiolist  --column "Selection" --column "Provider" 1 "1 - Amazon" 2 "2 - Azure" 3 "3 - DigitalOcean" 4 "4 - Google" 5 "5 - Linode" 6 "6 - Rackspace" | cut -c1-1)
  if [ $provider = "1" ]; then
      :
    else
      zenity --info --text="AWS not selected. Other providers are disabled on this system. Please contact BST-INTENG. Exiting" --timeout 8
      echo "100"
      echo "# Operation failed. Please try again."
      exit
  fi
export provider
awsregion=$(zenity  --list  --text "Where do you want the server to be located?" --radiolist  --column "Selection" --column "AWS Region" 1 "1 - Asia Pacific (Mumbai)" 2 "2 - Asia Pacific (Seoul)" 3 "3 - Asia Pacific (Singapore)" 4 "4 - Asia Pacific (Sydney)" 5 "5 - Asia Pacific (Tokyo)" 6 "6 - Canada (Central)" 7 "7 - EU (Frankfurt)" 8 "8 - EU (Ireland)" 9 "9 - EU (London)" 10 "10 - South America (Sao Paulo)" 11 "11 - US East (Northern Virginia)" 12 "12 - US East (Ohio)" 13 "13 - US West (Northern California)" 14 "14 - US West (Oregon)")
awsregionlist=$(echo $awsregion)
awsregion=$(echo $awsregion | cut -c1-2)
  if [[ "$awsregion" = "11" || "$awsregion" = "12" || "$awsregion" = "13" || "$awsregion" = "14" ]]
  then
      :
  else
       zenity --info --text="$awsregionlist, is not in the recomended regions list. System setup will continue, but we are unaware of the preformace degradation that using a unsupported region may cause." --width=500 --height=150 --timeout 5
  fi
  if [[ "$awsregion" = "1 " || "$awsregion" = "2 " || "$awsregion" = "3 " || "$awsregion" = "4 " || "$awsregion" = "5 " || "$awsregion" = "6 " || "$awsregion" = "7 " ]]
  then
    awsregion=$(echo $awsregion | cut -c1-1)
  else
    :
  fi
  if [[ "$awsregion" = "8 " || "$awsregion" = "9 " ]]
    then
      awsregion=$(echo $awsregion | cut -c1-1)
    else
      :
  fi
export awsregion
srvname="$(zenity --list --title="Set the hostname of the system" --column="Server Name (Double Click to Edit)" --editable Streisand)"
export srvname
vpc="$(zenity --list --title="Set the VPC of the system" --column="VPC (Double Click to Edit)" --editable "\n - Default")"
  if [[ "$vpc" = "\n - Default" ]]
  then
      vpc=$(echo $vpc | cut -c1-2)
  else
       :
  fi
export vpc
sub="$(zenity --list --title="Set the subbnet of the system" --column="Subbnet (Double Click to Edit)" --editable "\n - Default")"
  if [[ "$sub" = "\n - Default" ]]
  then
      sub=$(echo $sub | cut -c1-2)
  else
       :
  fi
export sub
awsak=$(zenity --forms --title="AWS User information" --add-password="AWS Access Key")
export awsak
awssk=$(zenity --forms --title="AWS User information" --add-password="AWS Secret Key")
export awssk
setup="\n"
export setup
# =================================================================
echo "80" >&${COPROC[1]}
echo "# Enabling expect service and switching to strisand" >&${COPROC[1]} ; sleep 5
echo "90" >&${COPROC[1]}
echo "# Striesand Deployment in progress, this should take about 10 minutes." >&${COPROC[1]}


/usr/bin/expect <<EOD
  set provider [puts $env(provider)]
  set awsregion [puts $env(awsregion)]
  set srvname [puts $env(srvname)]
  set awsak [puts $env(awsak)]
  set awssk [puts $env(awsak)]
  set vpc [puts $env(vpc)]
  set sub [puts $env(sub)]
  set setup [puts $env(setup)]
  spawn "./streisand"
  expect "Which provider are you using?*" {send $provider\r}
  expect "In what region should the server*" {send $awsregion\r}
  expect "Press enter to use the default V*" {send $vpc\r}
  expect "Press enter to use the default subnet.*" {send $sub\r}
  expect "What should the server be named? Press enter*" {send $srvname\r}
  expect "What is your AWS Access*" {send $awsak\r}
  expect "What is your AWS Secret*" {send $awssk\r}
  expect "Streisand will now set up your server. This*" {send $setup}
  expect eof
EOD
# =================================================================
echo "100" >&${COPROC[1]}
echo "# System Deployed." >&${COPROC[1]} ; sleep 1

zenity --question --title="AWS Streisand Server Deployment" --text="Would you like to preform cleanup? This is recomeneded."
  if [ $? = 0 ]
    then
      zenity --info -title "AWS Streisand Server Deployment" --text="Thank you for using a BST-INTENG product, cleanup will be preformed and we will exit."
      sudo rm -rf ./*
    else
    zenity --question --title="AWS Streisand Server Deployment" --text="Are you sure?"
      if [ $? = 0 ]
        then
            zenity --info -title "AWS Streisand Server Deployment" --text="Thank you for using a BST-INTENG product, we will now exit."
            exit
        else
            zenity --question --title="AWS Streisand Server Deployment" --text="Would you like to preform cleanup? This is recomeneded."
          if [ $? = 0 ]
            then
              zenity --info -title "AWS Streisand Server Deployment" --text="Thank you for using a BST-INTENG product, cleanup will be preformed and we will exit."
              sudo rm -rf ./*
            else
              zenity --info -title "AWS Streisand Server Deployment" --text="Thank you for using a BST-INTENG product, we will now exit."
              exit
      fi
    fi
  fi
