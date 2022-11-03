# Raspberry PI Utils

This repository contains scripts for convenient installation of HA and Robonomics integration on Raspberry Pi.

The following scripts are for public use:

 - `complete_install.sh` is to be used on a clean Ubuntu with python3.10 to install Home Assistant, IPFS, MQTT broker and Robonomics integration.
 - `install_integration_core.sh` - bash script to install IPFS and Robonomics integration into an existing Home Assistant Core.
 - `install_integration_docker.sh` - bash script to install IPFS and Robonomics integration into an existing Home Assistant Docker.
 - `install_ipfs_arc_dependent.sh` is used to install IPFS daemon and add it as a systemd service. Used in above-mentioned scripts.
 - `mqtt-install.sh` - bash script to install MQTT broker installation.


Other two scripts are for technical use. They are needed to create prebuilt and ready-yo-use RPI image.