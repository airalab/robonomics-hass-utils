#!/bin/bash

sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa -y
sudo apt update -y && sudo apt install mosquitto mosquitto-clients -y

echo "Please enter your username and press Enter"
read -p 'Enter username: ' USERNAME

read -sp 'Enter password: ' PASS

sudo mosquitto_passwd -b -c /etc/mosquitto/passwd $USERNAME $PASS

echo "listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd" | sudo tee /etc/mosquitto/conf.d/local.conf

sudo systemctl restart mosquitto
