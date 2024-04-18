#!/usr/bin/env bash

set -euo pipefail

ROOT=network-files
MARK_FILE=/root/network-files/MARK

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

source ./scripts/nodes-configuration.sh

# Kill all child processes on Ctrl+C
trap 'kill 0' INT

echo "Run"

if [ ! -f "$MARK_FILE" ]; then
  echo "Clean old state and logs"
  ./scripts/clean.sh

  echo "Creating local network files."
  ./scripts/make-babbage.sh
  ./network-files/run/all.sh &

    for ID in ${SP_NODES_ID}; do
      if [ -f "./scripts/pools/update-node-sp$ID.sh" ]; then # Only update the pool if a script exists for that pool.
        CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp"$ID"/node.sock ./scripts/pools/update-node-sp"$ID".sh
      fi
    done

    CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/plutus-transaction.sh
    CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/reference-input-transaction.sh
    CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/mint-tokens.sh
    CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/setup-wallets.sh
    CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/mint-handles.sh

    # We are going to mark the filesystem with a MARK file, so we can later detect when starting
    # the network if its bootstrapping from scratch or it was already initialized.
    touch "$MARK_FILE"
else
    echo "Skipping scripts execution because we are starting from a snapshot."
    #"$PWD"/bin/db-synthesizer --config "$PWD"/config/network/cardano-node/config.json --db "$PWD"/network-files/node-sp1/db/  --bulk-credentials-file "$PWD"/network-files/bulk-creds.json -b 10 -a
    ./network-files/run/all.sh &
fi

wait
