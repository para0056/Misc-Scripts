#!/bin/bash

# ===================================================================
# Purpose:           To automate the install of xRDP and XFCE.
# Parameters:        None
# Author:            Nick Paradis
# Notes:             Tested against Ubuntu 18.04-LTS on Microsoft Azure as a Linux Custom Script Extension.
# ===================================================================

# Update package list
apt-get update

# Install XRDP
apt-get install -y xrdp

# Disable newcursors because black background around cursor is displayed if using Xorg as session type.
sed -e 's/^new_cursors=true/new_cursors=false/g' -i /etc/xrdp/xrdp.ini
systemctl restart xrdp

apt-get install -y tasksel
tasksel install xubuntu-desktop
service lightdm start

# Install xubuntu desktop and automate selection of display manager
#apt install -y expect
#cat <<EOF | expect
#set timeout -1
#spawn sudo apt install -y xubuntu-desktop
#expect "Default display manager: "
#send "lightdm\n"
#expect eof
#EOF

apt-get update -y
apt-get upgrade -y
#sudo systemctl restart polkit
reboot
