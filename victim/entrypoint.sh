#!/bin/sh
set -eu

BOT_NETWORK="172.20.0.0/24"

echo "[victim] Starting..."
ROUTER_IP="$(getent hosts router | awk '{print $1}')"
if [ -z "$ROUTER_IP" ]; then
    echo "[victim] Could not resolve router"
    exit 1
fi

# Ideally for scenarios where there is a Reverse Proxy present, HTTP servers should respond through the Reverse Proxy
# instead of directly through the router. For sake of simplicity (and because it's midnight right now), this has been
# omitted

echo "[victim] Router: $ROUTER_IP"
ip route replace "$BOT_NETWORK" via "$ROUTER_IP"

echo "[victim] Routes:"
ip route

# Implementing a firewall to restrict direct calls from outside to the HTTP server. Server will only serve
# authorised addresses (i.e. NGINX)

if [ "${FIREWALL_ENABLED:-false}" = "true" ]; then
    echo "[victim] Enabling HTTP firewall..."
    NGINX_IP_INET="192.0.2.3"

    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp -s $NGINX_IP_INET --dport 9000 -j ACCEPT # Allow HTTP only from NGINX
    iptables -A INPUT -p tcp --dport 9000 -j DROP                     # Drop all other HTTP requests
else
    echo "[victim] HTTP firewall disabled (baseline)"
fi

echo "[victim] Starting server..."
exec su-exec node node server.js