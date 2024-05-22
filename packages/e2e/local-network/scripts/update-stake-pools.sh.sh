#!/usr/bin/env bash

set -euo pipefail

SP_NODES_ID="$1"

for ID in ${SP_NODES_ID}; do
  if [ -f "./scripts/pools/update-node-sp$ID.sh" ]; then # Only update the pool if a script exists for that pool.
    CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp"$ID"/node.sock ./scripts/pools/update-node-sp"$ID".sh &
  fi
done

wait
