#!/usr/bin/env bash

arc=$(uname -m)
echo $arc
if [ $arc = "x86_64" ]; then
    wget https://dist.ipfs.io/go-ipfs/v0.14.0/go-ipfs_v0.14.0_linux-amd64.tar.gz
    tar -xvzf go-ipfs_v0.14.0_linux-amd64.tar.gz
    rm go-ipfs_v0.14.0_linux-amd64.tar.gz
elif [ $arc = "aarch64" ]; then
    wget https://dist.ipfs.io/go-ipfs/v0.14.0/go-ipfs_v0.14.0_linux-arm64.tar.gz
    tar -xvzf go-ipfs_v0.14.0_linux-arm64.tar.gz
    rm go-ipfs_v0.14.0_linux-arm64.tar.gz
else
    wget https://dist.ipfs.io/go-ipfs/v0.14.0/go-ipfs_v0.14.0_linux-arm.tar.gz
    tar -xvzf go-ipfs_v0.14.0_linux-arm.tar.gz
    rm go-ipfs_v0.14.0_linux-arm.tar.gz
fi

cd go-ipfs
sudo bash install.sh
cd ..
rm -rf go-ipfs
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

echo "IPFS daemon installed and launched, use ipfs-daemon.service to manage."
