#!/usr/bin/env bash

wget https://raw.githubusercontent.com/airalab/robonomics-hass-utils/main/raspberry_pi/install_ipfs_arc_dependent.sh
bash install_ipfs_arc_dependent.sh
rm install_ipfs_arc_dependent.sh

sudo -u homeassistant -H -s bash -c "cd /home/homeassistant/.homeassistant &&
                                     mkdir custom_components &&
                                     cd custom_components &&
                                     wget https://github.com/airalab/homeassistant-robonomics-integration/archive/refs/tags/1.5.2.zip &&
                                     unzip 1.5.2.zip &&
                                     mv homeassistant-robonomics-integration-1.5.2/custom_components/robonomics . &&
                                     rm -r homeassistant-robonomics-integration-1.5.2 &&
                                     rm 1.5.2.zip"

echo "Integration downloaded!"