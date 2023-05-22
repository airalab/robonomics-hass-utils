#!/bin/bash

FILE=/home/$USER/.ipfs/check

if [ -f "$FILE" ]; then
    echo "IPFS initialized. Start IPFS daemon"
    exit 0
else
    echo "IPFS isn't initialized. Start initializing process"

    cd /home/$USER
    rm -rf .ipfs/
    ipfs init -p local-discovery
    ipfs bootstrap add /dns4/1.pubsub.aira.life/tcp/443/wss/ipfs/QmdfQmbmXt6sqjZyowxPUsmvBsgSGQjm4VXrV7WGy62dv8
    ipfs bootstrap add /dns4/2.pubsub.aira.life/tcp/443/wss/ipfs/QmPTFt7GJ2MfDuVYwJJTULr6EnsQtGVp8ahYn9NSyoxmd9
    ipfs bootstrap add /dns4/3.pubsub.aira.life/tcp/443/wss/ipfs/QmWZSKTEQQ985mnNzMqhGCrwQ1aTA6sxVsorsycQz9cQrw
    ipfs bootstrap add /dns4/ipfs-gateway.multi-agent.io/tcp/4001/ipfs/12D3KooWAuRhU7tnQ3cVQxvvdEHZ4pnfwipMtDL3oxZuzk9wP649


    touch "$FILE"
    echo "IPFS initialized. Start IPFS daemon"

    echo "initializing yggdrasil"

    yggdrasil -genconf -json > ./ygg.conf

    jq '.Peers = input' ygg.conf input.json > yggdrasil.conf

    chmod 664 yggdrasil.conf
    sudo mv yggdrasil.conf /etc/
    rm ygg.conf
    rm input.json
    echo "initialized yggdrasil"
fi

# create password for mqtt. Then  save it in home directory and provide this data to z2m configuration

cd /home/$USER

# mqtt

PASSWD=$(openssl rand -hex 10)
echo "mqtt user - connectivity
mqtt password - $PASSWD" > mqtt.txt

sudo mosquitto_passwd -b -c /etc/mosquitto/passwd connectivity $PASSWD
sudo systemctl restart mosquitto

#zigbee2mqtt

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
  port: /dev/ttyUSB0 # /dev/ttyUSB0 for example

" | sudo tee /opt/zigbee2mqtt/data/configuration.yaml

# mqtt integration

echo "{
  "version": 1,
  "minor_version": 1,
  "key": "core.config_entries",
  "data": {
    "entries": [
      {
        "entry_id": "92c28c246bb8163e5cc9e6dc5b5d8606",
        "version": 1,
        "domain": "mqtt",
        "title": "localhost",
        "data": {
          "broker": "localhost",
          "port": 1883,
          "username": "connectivity",
          "password": "$PASSWD",
          "discovery": true,
          "discovery_prefix": "homeassistant"
        },
        "options": {},
        "pref_disable_new_entities": false,
        "pref_disable_polling": false,
        "source": "user",
        "unique_id": null,
        "disabled_by": null
      }
    ]
  }
}


" | sudo tee /home/homeassistant/.homeassistant/.storage/core.config_entries