#!/usr/bin/bash
set -euo pipefail

# This script adds a new rule for firewall to allow local-to-docker-network bridge. It was initially dropping packets
# coming from the bridge

BOT_SUBNET="172.20.0.0/24"
VTM_SUBNET="192.0.2.0/24"
PORT="8080"

echo "[+] Allowing Docker bridge → C2 port ${PORT}"
sudo ufw allow in from "$BOT_SUBNET" to any port "$PORT" proto tcp
sudo ufw route allow from "$BOT_SUBNET" to "$VTM_SUBNET"

echo
sudo ufw status numbered