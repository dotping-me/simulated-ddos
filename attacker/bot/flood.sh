#!/usr/bin/bash
set -euo pipefail

TARGET=$1
COUNT=100

echo "[A] Attacking ${TARGET} (${COUNT})" >&2
wget -qO- $TARGET > /dev/null
