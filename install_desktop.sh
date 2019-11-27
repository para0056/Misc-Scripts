#!/bin/sh

# Update Ubuntu
sudo apt-get update -y

# Install Desktop Enviornment 
# Tasksel
#sudo tasksel install ubuntu-mate-core
#tasksel --list-task
#sudo apt-get install -y tasksel
#sudo tasksel install ubuntu-mate-core

# Install xubuntu desktop environment
sudo apt-get install -y xubuntu-desktop
sudo service lightdm start

# Install XRDP
sudo apt-get install -y xrdp

#* Disable newcursors because black background around cursor is displayed if using Xorg as session type.
sed -e 's/^new_cursors=true/new_cursors=false/g' -i /etc/xrdp/xrdp.ini
systemctl restart xrdp
