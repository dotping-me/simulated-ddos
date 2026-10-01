#!/bin/bash
set -euo pipefail

COUNT="${COUNT:-100}"

read -r IP PORT <<<"${1:?usage: $0 <ip> <port>}"
URL="http://${IP}:${PORT}/"

sent=0
for (( i = 1; i <= COUNT; i++ )); do
    wget -q -O /dev/null -T 3 -t 1 "$URL" && sent=$((sent + 1))
done

echo "[+] ${sent}/${COUNT} requests sent to $URL"

(( sent > 0 ))
