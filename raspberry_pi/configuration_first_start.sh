#!/bin/bash

FILE=/root/.check

if [ -f "$FILE" ]; then
    echo "All configuration files already set. Nothing to do"
    exit 0
else
    echo "Create configuration files"
    cd /root
    echo "initializing yggdrasil"

    curl -O https://raw.githubusercontent.com/airalab/robonomics-hass-utils/main/raspberry_pi/input.json

    yggdrasil -genconf -json > ./ygg.conf

    jq '.Peers = input' ygg.conf input.json > yggdrasil.conf

    chmod 664 yggdrasil.conf
    mv yggdrasil.conf /etc/
    rm ygg.conf
    rm input.json
    echo "initialized yggdrasil"

    # create password for mqtt. Then  save it in home directory and provide this data to z2m configuration
    # mqtt

    PASSWD=$(openssl rand -hex 10)

    mosquitto_passwd -b -c /etc/mosquitto/passwd connectivity $PASSWD
    systemctl restart mosquitto

    #zigbee2mqtt

    Z2MPATH=$(ls /dev/serial/by-path/)
    Z2MPATH="/dev/serial/by-path/"$Z2MPATH

    echo "# Home Assistant integration (MQTT discovery)
homeassistant: true

# allow new devices to join
permit_join: false

# MQTT settings
mqtt:
  # MQTT base topic for zigbee2mqtt MQTT messages
  base_topic: zigbee2mqtt
  # MQTT server URL
  server: 'mqtt://localhost'
  # MQTT server authentication, uncomment if required:
  user: connectivity
  password: $PASSWD

frontend:
  # Optional, default 8080
  port: 8099

# Serial settings
serial:
  # Location of CC2531 USB sniffer
  port: $Z2MPATH

    " | tee /opt/zigbee2mqtt/data/configuration.yaml

    # mqtt integration

    echo "{
  \"version\": 1,
  \"minor_version\": 1,
  \"key\": \"core.config_entries\",
  \"data\": {
    \"entries\": [
      {
        \"entry_id\": \"92c28c246bb8163e5cc9e6dc5b5d8606\",
        \"version\": 1,
        \"domain\": \"mqtt\",
        \"title\": \"localhost\",
        \"data\": {
          \"broker\": \"localhost\",
          \"port\": 1883,
          \"username\": \"connectivity\",
          \"password\": \"$PASSWD\",
          \"discovery\": true,
          \"discovery_prefix\": \"homeassistant\"
        },
        \"options\": {},
        \"pref_disable_new_entities\": false,
        \"pref_disable_polling\": false,
        \"source\": \"user\",
        \"unique_id\": null,
        \"disabled_by\": null
      }
    ]
  }
}
" | tee /home/homeassistant/.homeassistant/.storage/core.config_entries

    systemctl enable home-assistant@homeassistant.service
    systemctl start home-assistant@homeassistant.service

    touch "$FILE"
fi