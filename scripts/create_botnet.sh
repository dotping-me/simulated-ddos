#!/usr/bin/bash

# This script invokes the Docker API to create containers (acting as bots)

# Creates docker network
if ! sudo docker network inspect bot_network >/dev/null 2>&1; then
    echo "[+] Creating bot network"
    sudo docker network create \
        --driver bridge \
        --subnet 172.20.0.0/24 \
        bot_network
fi

COUNT=${1:-5} # Takes in user input for N bots
for ((i=1; i<=COUNT; i++)); do
    NAME=$(printf "bot_%03d" "$i")
    echo "[+] Starting $NAME"
    
    # Remove any existing container
    if sudo docker container inspect "$NAME" &>/dev/null; then
        sudo docker rm -f "$NAME" >/dev/null
    fi

    sudo docker run -d \
    --name "$NAME" \
    --network bot_network \
    --add-host=host.docker.internal:host-gateway \
    bot_image \
    --master ws://host.docker.internal:8080/connect

    # If victim_network exists, creates connection to it. I don't know why just using Docker Compose and manually 
    # creating the network using Docker Network did not work even though everything looked good: IP Forwarding, Rule sets, ...
    if sudo docker network inspect victim_network >/dev/null 2>&1; then
        echo "[+] Connecting $NAME to victim_network"
        sudo docker network connect victim_network "$NAME"
    else
        echo "[!] victim_network does not exist; skipping connection"
    fi

done