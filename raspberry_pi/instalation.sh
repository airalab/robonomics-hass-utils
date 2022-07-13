#!/usr/bin/env bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff5 tzdata libcurl4-openssl-dev

sudo useradd -rm homeassistant
sudo mkdir /srv/homeassistant
sudo chown homeassistant:homeassistant /srv/homeassistant

cd /srv/homeassistant
sudo -u homeassistant -H -s python3 -m venv .
sudo -u homeassistant -H -s bash -c "source bin/activate &&
        pip3 install wheel"
        
sudo -u homeassistant -H -s bash -c "source bin/activate &&
				     pip install aiodiscover==1.4.11"

sudo -u homeassistant -H -s bash -c "source bin/activate &&
				     pip3 install homeassistant && 
        			     timeout 60s hass"
			     

echo "DONE WITH ha"

sudo apt update -y && sudo apt install mosquitto mosquitto-clients -y

sudo mosquitto_passwd -b -c /etc/mosquitto/passwd user pass

echo "listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd" | sudo tee -a /etc/mosquitto/mosquitto.conf

sudo systemctl restart mosquitto

echo "DONE WITH mqtt"

cd /home/$USER
wget https://dist.ipfs.io/go-ipfs/v0.12.2/go-ipfs_v0.12.2_linux-arm64.tar.gz
tar -xvzf go-ipfs_v0.12.2_linux-arm64.tar.gz
rm go-ipfs_v0.12.2_linux-arm64.tar.gz
cd go-ipfs
sudo bash install.sh
ipfs init

echo "[Unit]
Description=IPTS Daemon Service

[Service]
Type=simple
ExecStart=/usr/local/bin/ipfs daemon
User=$USER

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/ipfs-daemon.service

sudo systemctl enable ipfs-daemon.service
sudo systemctl start ipfs-daemon.service

echo "DONE WITH IPFS"

echo "[Unit]
Description=Home Assistant
After=network-online.target
[Service]
Type=simple
User=%i
WorkingDirectory=/srv/%i/
ExecStart=/srv/homeassistant/bin/hass -c "/home/%i/.homeassistant"
Environment="PATH=/srv/%i/bin"

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/home-assistant@homeassistant.service


sudo systemctl enable home-assistant@homeassistant.service
sudo systemctl start home-assistant@homeassistant.service

echo "DONE WITH ha part 2"

cd /srv/homeassistant

sudo -u homeassistant -H -s bash -c "source bin/activate &&
        pip3 install http3 &&
        pip3 install robonomics-interface~=1.0"

sudo -u homeassistant -H -s bash -c "cd /home/homeassistant/.homeassistant &&
                                     mkdir custom_components &&
                                     cd custom_components &&
                                     git clone https://github.com/LoSk-p/robonomics_smart_home.git"
sudo systemctl restart home-assistant@homeassistant.service


