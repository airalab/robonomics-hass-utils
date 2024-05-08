#!/usr/bin/env bash
# save current path to return later
CURRENT_PATH=$(pwd)
if [ -x "$(command -v docker)" ]; then
    echo "Docker installed"
    # command
else
    echo "Please, install docker first!"
    exit
fi

# check if user in docker group
if id -nG "$USER" | grep -qw "docker"; then
    echo "$USER belongs to the docker group"
else
    echo "$USER does not belong to docker. Please add $USER to the docker group."
    exit 1
fi

if [[ -f 001-test.sh ]]
then
  echo "IPFS setup file exists"
else
  wget https://raw.githubusercontent.com/tubleronchik/robonomics-hass-utils/main/raspberry_pi/001-test.sh
fi

if [[ -f core_compose.yaml ]]
then
  echo "Compose file exists"
else
  wget https://raw.githubusercontent.com/tubleronchik/robonomics-hass-utils/main/raspberry_pi/core_compose.yaml
fi

# create IPFS repositories
if [[ -d ./ipfs/data ]]
then
  echo "IPFS directory already exist"
else
  mkdir -p "ipfs/data"
  mkdir -p "ipfs/staging"
fi

if [[ -d ./libp2p-ws-proxy ]]
then
  echo "libp2p-ws-proxy directory already exist"
else
  #libp2p
  git clone https://github.com/PinoutLTD/libp2p-ws-proxy.git
  echo "PEER_ID_CONFIG_PATH="peerIdJson.json"
  RELAY_ADDRESS="/dns4/libp2p-relay-1.robonomics.network/tcp/443/wss/p2p/12D3KooWEMFXXvpZUjAuj1eKR11HuzZTCQ5HmYG9MNPtsnqPSERD"
  SAVED_DATA_DIR_PATH="saved_data"
  " > libp2p-ws-proxy/.env
fi

# return to the directory with compose
cd $CURRENT_PATH
docker compose -f core_compose.yaml up -d


echo "Integration downloaded!"