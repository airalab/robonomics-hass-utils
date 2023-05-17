#!/usr/bin/env bash

wget https://raw.githubusercontent.com/airalab/robonomics-hass-utils/main/raspberry_pi/install_ipfs_arc_dependent.sh
bash install_ipfs_arc_dependent.sh
rm install_ipfs_arc_dependent.sh

sudo echo "
cd /config
mkdir custom_components
cd custom_components
wget https://github.com/airalab/homeassistant-robonomics-integration/archive/refs/tags/1.5.3.zip &&
                                     unzip 1.5.3.zip &&
                                     mv homeassistant-robonomics-integration-1.5.3/custom_components/robonomics . &&
                                     rm -r homeassistant-robonomics-integration-1.5.3 &&
                                     rm 1.5.3.zip" | docker exec -i homeassistant bash

echo "Integration downloaded!"
