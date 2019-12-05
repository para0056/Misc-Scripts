#!/bin/bash

# ===================================================================
# Purpose:           To automate the install of xRDP and XFCE.
# Parameters:        None
# Author:            Nick Paradis
# Notes:             Tested against Ubuntu 18.04-LTS on Microsoft Azure as a Linux Custom Script Extension.
# ===================================================================

# Update package list
sudo apt-get update -y

# Install XRDP
sudo apt-get install -y xrdp

# Disable newcursors because black background around cursor is displayed if using Xorg as session type.
sudo sed -e 's/^new_cursors=true/new_cursors=false/g' -i /etc/xrdp/xrdp.ini
sudo systemctl restart xrdp

# Install tasksel and use to install XFCE
sudo apt-get install -y tasksel
sudo tasksel install xubuntu-desktop

# Start the lightdm display manager
sudo service lightdm start

# One last reboot
reboot
