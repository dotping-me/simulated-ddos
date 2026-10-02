#!/bin/sh
set -eu

VICTIM_NETWORK="192.0.2.0/24"

echo "[bot] Starting..."
ROUTER_IP="$(getent hosts router | awk '{print $1}')" # Docker DNS resolves the router on bot_network.
if [ -z "$ROUTER_IP" ]; then
    echo "[bot] Could not resolve router"
    exit 1
fi

echo "[bot] Router: $ROUTER_IP"
ip route replace "$VICTIM_NETWORK" via "$ROUTER_IP"

echo "[bot] Routes:"
ip route

echo "[bot] Starting bot..."
exec su-exec bot /bot "$@" # Continues script execution