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
    rm ygg.conf
    sudo mv yggdrasil.conf /etc/yggdrasil/
    sudo systemctl enable yggdrasil
    sudo systemctl start yggdrasil
    echo "initialized yggdrasil"
fi