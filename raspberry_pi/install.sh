#!/usr/bin/env bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff5 tzdata libcurl4-openssl-dev subversion

sudo useradd -rm homeassistant
sudo mkdir /srv/homeassistant
sudo chown homeassistant:homeassistant /srv/homeassistant

cd /srv/homeassistant
sudo -u homeassistant -H -s python3 -m venv .
sudo -u homeassistant -H -s bash -c "source bin/activate &&
        pip3 install wheel~=0.37"
        
sudo -u homeassistant -H -s bash -c "source bin/activate &&
				     pip3 install sqlalchemy~=1.4 fnvhash~=0.1 aiodiscover==1.4.11"

sudo -u homeassistant -H -s bash -c "source bin/activate &&
				     pip3 install homeassistant==2022.8.2 && 
        			     timeout 60s hass"
			     

echo "DONE WITH ha"

cd /home/$USER
wget https://dist.ipfs.io/go-ipfs/v0.14.0/go-ipfs_v0.14.0_linux-arm64.tar.gz
tar -xvzf go-ipfs_v0.14.0_linux-arm64.tar.gz
rm go-ipfs_v0.14.0_linux-arm64.tar.gz
cd go-ipfs
sudo bash install.sh
ipfs init -p local-discovery
ipfs bootstrap add /dns4/1.pubsub.aira.life/tcp/443/wss/ipfs/QmdfQmbmXt6sqjZyowxPUsmvBsgSGQjm4VXrV7WGy62dv8
ipfs bootstrap add /dns4/2.pubsub.aira.life/tcp/443/wss/ipfs/QmPTFt7GJ2MfDuVYwJJTULr6EnsQtGVp8ahYn9NSyoxmd9
ipfs bootstrap add /dns4/3.pubsub.aira.life/tcp/443/wss/ipfs/QmWZSKTEQQ985mnNzMqhGCrwQ1aTA6sxVsorsycQz9cQrw


echo "[Unit]
Description=IPFS Daemon Service

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

sudo curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs git make g++ gcc

node --version 
npm --version

sudo mkdir /opt/zigbee2mqtt
sudo chown -R ${USER}: /opt/zigbee2mqtt

git clone --depth 1 --branch 1.28.0 https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt

cd /opt/zigbee2mqtt
npm ci


echo "Done with Zigbee2MQTT"

echo "[Unit]
Description=Home Assistant
After=network-online.target
[Service]
Type=simple
Restart=on-failure

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
        pip3 install robonomics-interface~=1.3"

sudo -u homeassistant -H -s bash -c "cd /home/homeassistant/.homeassistant &&
                                     mkdir custom_components &&
                                     cd custom_components &&
                                     svn checkout https://github.com/airalab/homeassistant-robonomics-integration/trunk/custom_components/robonomics"
                                     
sudo systemctl restart home-assistant@homeassistant.service
sudo systemctl restart home-assistant@homeassistant.service


echo "Clear garbage"
cd /home/$USER
rm -r go-ipfs/
rm install.sh

echo "Garbage collected"