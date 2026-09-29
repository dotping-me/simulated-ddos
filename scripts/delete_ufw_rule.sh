#!/usr/bin/bash
set -euo pipefail

BOT_SUBNET="172.20.0.0/24"
VTM_SUBNET="192.0.2.0/24"
PORT="8080"

echo "[-] Removing Docker bridge → C2 port ${PORT} rule"
sudo ufw delete allow in from "$BOT_SUBNET" to any port "$PORT" proto tcp

echo "[-] Removing Docker bridge → victim network forwarding rule"
sudo ufw route delete allow from "$BOT_SUBNET" to "$VTM_SUBNET"

echo
sudo ufw status numbered