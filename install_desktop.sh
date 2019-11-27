#!/bin/sh

# Update Ubuntu
sudo apt-get update -y

# Install Desktop Enviornment 
sudo tasksel install ubuntu-mate-core
tasksel --list-task
sudo apt-get install tasksel -y
sudo tasksel install ubuntu-mate-core
sudo service lightdm start

# Install XRDP
sudo apt-get -y install xrdp

#* Disable newcursors because black background around cursor is displayed if using Xorg as session type.
sed -e 's/^new_cursors=true/new_cursors=false/g' -i /etc/xrdp/xrdp.ini
systemctl restart xrdp
