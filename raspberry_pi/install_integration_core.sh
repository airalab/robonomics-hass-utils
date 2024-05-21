#!/usr/bin/env bash
# save current path to return later
CURRENT_PATH=$(pwd)
if [ -x "$(command -v docker)" ]; then
    echo "Docker installed"
    # command
else
    echo "Please, install docker first!"
    exit 1
fi

# check if user in docker group
if id -nG "$USER" | grep -qw "docker"; then
    echo "$USER belongs to the docker group"
else
    echo "$USER does not belong to docker. Please add $USER to the docker group."
    exit 1
fi

# check if ipfs exists
echo "Checking if IPFS installed... It may take few minutes. Please wait"
IP_ADDR=$(hostname -I | awk '{print $1}')
http_status=$(curl -o /dev/null -s -w "%{http_code}" http://$IP_ADDR:8080/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/)

if [[ $http_status -eq 200 ]]; 
then
  read -p "IPFS instance has been found. Make sure that your configuration is set up properly with the following settings:
      - 'Gateway': '/ip4/0.0.0.0/tcp/8080'
      - Ports 4001, 5001, and 8080 are available.
      Also, add the following bootstrap nodes:
      1. '/dns4/1.pubsub.aira.life/tcp/443/wss/ipfs/QmdfQmbmXt6sqjZyowxPUsmvBsgSGQjm4VXrV7WGy62dv8'
      2. '/dns4/2.pubsub.aira.life/tcp/443/wss/ipfs/QmPTFt7GJ2MfDuVYwJJTULr6EnsQtGVp8ahYn9NSyoxmd9'
      3. '/dns4/3.pubsub.aira.life/tcp/443/wss/ipfs/QmWZSKTEQQ985mnNzMqhGCrwQ1aTA6sxVsorsycQz9cQrw'
      Is your config set up properly? [yes/no]: " answer
      answer=${answer:-no}

  # Convert the user input to lowercase
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

  if [[ $answer == "no" ]] 
  then
    echo "Abort."
    exit 1
  else
    echo "Pulling libp2p-ws-proxy image and running the container..."
    docker pull ghcr.io/pinoutltd/libp2p-ws-proxy:latest
    docker run --name libp2p-proxy --detach -p 127.0.0.1:8888:8888 -p 127.0.0.1:9999:9999 ghcr.io/pinoutltd/libp2p-ws-proxy:latest
    exit 0
  fi
fi


if [[ -f 001-test.sh ]]
then
  echo "IPFS setup file exists"
else
  wget https://raw.githubusercontent.com/tubleronchik/robonomics-hass-utils/main/raspberry_pi/001-test.sh
fi

if [[ -f core_compose_with_ipfs.yaml ]]
then
  echo "Compose file exists"
else
  wget https://raw.githubusercontent.com/tubleronchik/robonomics-hass-utils/main/raspberry_pi/core_compose_with_ipfs.yaml
fi

# create IPFS repositories
if [[ -d ./ipfs/data ]]
then
  echo "IPFS directory already exist"
else
  mkdir -p "ipfs/data"
  mkdir -p "ipfs/staging"
fi

# return to the directory with compose
cd $CURRENT_PATH
docker compose -f core_compose_with_ipfs.yaml up -d


echo "Integration downloaded!"