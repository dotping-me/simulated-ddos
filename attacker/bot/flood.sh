#!/usr/bin/bash
set -euo pipefail

TARGET=$1
COUNT=1 # Capped to 1 for now because attack does not stop until script finishes workload

echo "[A] Attacking ${TARGET} (${COUNT})" >&2
wget -qO- $TARGET > /dev/null
