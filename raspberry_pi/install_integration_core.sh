#!/usr/bin/env bash

sudo apt-get install unzip
wget https://raw.githubusercontent.com/airalab/robonomics-hass-utils/main/raspberry_pi/install_ipfs_arc_dependent.sh
bash install_ipfs_arc_dependent.sh
rm install_ipfs_arc_dependent.sh

sudo -u homeassistant -H -s bash -c "cd /home/homeassistant/.homeassistant &&
                                     mkdir custom_components"
sudo -u homeassistant -H -s bash -c "cd /home/homeassistant/.homeassistant/custom_components &&
                                     wget https://github.com/airalab/homeassistant-robonomics-integration/archive/refs/tags/1.6.1.zip &&
                                     unzip 1.6.1.zip &&
                                     mv homeassistant-robonomics-integration-1.6.1/custom_components/robonomics . &&
                                     rm -r homeassistant-robonomics-integration-1.6.1 &&
                                     rm 1.6.1.zip"

echo "Integration downloaded!"