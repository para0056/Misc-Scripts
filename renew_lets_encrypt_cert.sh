#!/bin/bash
#Put this script in /home/renew_lets_encrypt_cert.sh
# Setup your Domain und E-Mail
domain="unifi.casanaley.net"
email="nick@nparadis.ca"

# Stop the services
service nginx stop
service unifi stop

# Get the certificate from LetsEncrypt
/home/letsencrypt/letsencrypt-auto certonly --text --standalone --preferred-challenges tls-sni-01 --domain $domain --email $email --agree-tos --renew-by-default

# Convert cert to PKCS #12 format
openssl pkcs12 -export -inkey /etc/letsencrypt/live/$domain/privkey.pem -in /etc/letsencrypt/live/$domain/fullchain.pem -out /home/cert.p12 -name ubnt -password pass:temppass

# Load it into the java keystore that UBNT understands
keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /usr/lib/unifi/data/keystore -srckeystore /home/cert.p12 -srcstoretype PKCS12 -srcstorepass temppass -alias ubnt -noprompt

# Clean up and use new cert
rm /home/cert.p12

# Also use the same certificate for Nginx (Cloud Key Configuration)
rm /etc/ssl/private/cloudkey.crt
rm /etc/ssl/private/cloudkey.key
rm /etc/ssl/private/unifi.keystore.jks
rm /etc/ssl/private/cert.tar
cp /etc/letsencrypt/live/$domain/privkey.pem /etc/ssl/private/cloudkey.key
cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/ssl/private/cloudkey.crt
cp /usr/lib/unifi/data/keystore /etc/ssl/private/unifi.keystore.jks
cd /etc/ssl/private/
tar -cf cert.tar cloudkey.crt cloudkey.key unifi.keystore.jks

#Start the services
service nginx start
service unifi start