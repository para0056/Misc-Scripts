#!/bin/bash
#Put this script in /home/setup_lets_encrypt_service.sh
# Goto home directory
cd /home/

# Install needed packages
sudo apt-get update
sudo apt-get install -y git

# Clone LE from GIT
git clone https://github.com/letsencrypt/letsencrypt
letsencrypt/letsencrypt-auto

# Stop unifi service
service unifi stop

# Remove old keystore symlink
rm /usr/lib/unifi/data/keystore

# Delete keystore line in unifi config
cat /etc/default/unifi | sed '/^UNIFI_SSL_KEYSTORE/ d' > unifi_new
rm /etc/default/unifi
mv unifi_new /etc/default/unifi

# Get and setup certificate from LE
/home/renew_lets_encrypt_cert.sh