#!/bin/sh
set -eu

BOT_IF="eth0"
VICTIM_IF="eth1"
BOT_NETWORK="172.20.0.0/24" 
VICTIM_NETWORK="192.0.2.0/24"

echo "[router] Starting..."

# Ensures proper interface ordering
BOT_IF="$(ip -o -4 addr show | awk '$4 ~ /^172\.20\.0\./ {print $2; exit}')"
VICTIM_IF="$(ip -o -4 addr show | awk '$4 ~ /^192\.0\.2\./ {print $2; exit}')"
if [ -z "$BOT_IF" ] || [ -z "$VICTIM_IF" ]; then
    echo "[router] Could not determine network interfaces"
    exit 1
fi

echo "[router] Bot interface:    $BOT_IF"
echo "[router] Victim interface: $VICTIM_IF"

echo "[router] Interfaces:"
ip -br addr

ip route replace "$BOT_NETWORK" dev "$BOT_IF"
ip route replace "$VICTIM_NETWORK" dev "$VICTIM_IF"

echo "[router] IPv4 forwarding enabled."
echo "[router] Routing table:"
ip route

echo "[router] Ready."
exec sleep infinity # Keeps router alive