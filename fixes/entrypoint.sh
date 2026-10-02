#!/bin/sh

BOT_NETWORK="172.20.0.0/24" 
ROUTER_IP_INET="192.0.2.2" # TODO: Would have been great if these were env variables

ip route add $BOT_NETWORK via $ROUTER_IP_INET
exec nginx -g "daemon off;"