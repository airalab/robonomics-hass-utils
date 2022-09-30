#!/bin/bash

FILE=/home/$USER/.ipfs/check

if [ -f "$FILE" ]; then
    echo "IPFS initialed. Start IPFS daemon"
    exit 0
else
    echo "IPFS isn't initialed. Start initialing process"

    cd /home/$USER
    rm -rf .ipfs/
    ipfs init -p local-discovery
    ipfs bootstrap add /dns4/1.pubsub.aira.life/tcp/443/wss/ipfs/QmdfQmbmXt6sqjZyowxPUsmvBsgSGQjm4VXrV7WGy62dv8
    ipfs bootstrap add /dns4/2.pubsub.aira.life/tcp/443/wss/ipfs/QmPTFt7GJ2MfDuVYwJJTULr6EnsQtGVp8ahYn9NSyoxmd9
    ipfs bootstrap add /dns4/3.pubsub.aira.life/tcp/443/wss/ipfs/QmWZSKTEQQ985mnNzMqhGCrwQ1aTA6sxVsorsycQz9cQrw

    touch "$FILE"
    echo "IPFS initialed. Start IPFS daemon"

fi