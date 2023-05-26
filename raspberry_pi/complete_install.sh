#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-dev python3-venv python3-pip bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff5 libturbojpeg0-dev tzdata libcurl4-openssl-dev python3-serial curl unzip

sudo useradd -rm homeassistant
sudo mkdir /srv/homeassistant
sudo chown homeassistant:homeassistant /srv/homeassistant
sudo usermod -a -G tty homeassistant
sudo usermod -a -G dialout homeassistant

cd /srv/homeassistant
sudo -u homeassistant -H -s python3 -m venv .
sudo -u homeassistant -H -s bash -c "source bin/activate &&
        pip3 install wheel~=0.37"
        
sudo -u homeassistant -H -s bash -c "source bin/activate &&
				     pip3 install sqlalchemy~=1.4 fnvhash~=0.1 aiodiscover==1.4.11"

sudo -u homeassistant -H -s bash -c "source bin/activate &&
				     pip3 install homeassistant==2023.5.3 psutil-home-assistant~=0.0 &&
        			     timeout 60s hass"
			     

echo "DONE WITH ha"
echo "install yggdrasil"

sudo apt-get install -y jq dirmngr

cd
wget https://github.com/yggdrasil-network/yggdrasil-go/releases/download/v0.4.7/yggdrasil-0.4.7-arm64.deb
sudo dpkg -i yggdrasil-0.4.7-arm64.deb
rm -f /etc/yggdrasil.conf

cd /home/${USER}
curl -O https://raw.githubusercontent.com/airalab/robonomics-hass-utils/main/raspberry_pi/input.json

echo "done with yggdrasil"
echo "install ipfs"

wget https://raw.githubusercontent.com/airalab/robonomics-hass-utils/main/raspberry_pi/install_ipfs_arc_dependent.sh
bash install_ipfs_arc_dependent.sh
rm install_ipfs_arc_dependent.sh

echo "done with ipfs"
echo "install z2m"

sudo curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs git make g++ gcc

node --version 
npm --version

sudo mkdir /opt/zigbee2mqtt
sudo chown -R ${USER}: /opt/zigbee2mqtt
git clone --depth 1 --branch 1.28.4 https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt

cd /opt/zigbee2mqtt
npm ci

sudo chown -R homeassistant: /opt/zigbee2mqtt

  echo "[Unit]
Description=zigbee2mqtt
After=network.target

[Service]
ExecStart=/usr/bin/npm start
WorkingDirectory=/opt/zigbee2mqtt
StandardOutput=inherit
StandardError=inherit
RestartSec=15
Restart=always
User=homeassistant

[Install]
WantedBy=multi-user.target
  " | sudo tee /etc/systemd/system/zigbee2mqtt.service

sudo systemctl enable zigbee2mqtt.service
sudo systemctl start zigbee2mqtt.service

echo "Done with Zigbee2MQTT"
echo "HA part 2 install"

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



cd /srv/homeassistant

sudo -u homeassistant -H -s bash -c "source bin/activate &&
        pip3 install robonomics-interface~=1.6"

sudo -u homeassistant -H -s bash -c "cd /home/homeassistant/.homeassistant &&
                                     mkdir custom_components &&
                                     cd custom_components &&
                                     wget https://github.com/airalab/homeassistant-robonomics-integration/archive/refs/tags/1.5.5.zip &&
                                     unzip 1.5.5.zip &&
                                     mv homeassistant-robonomics-integration-1.5.5/custom_components/robonomics . &&
                                     rm -r homeassistant-robonomics-integration-1.5.5 &&
                                     rm 1.5.5.zip "

sudo systemctl restart home-assistant@homeassistant.service
echo "DONE WITH ha part 2"

echo "Clear garbage"
cd /home/$USER
rm complete_install.sh input.json yggdrasil-0.4.7-arm64.deb

echo "Garbage collected"
