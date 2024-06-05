#!/usr/bin/env bash

set -euo pipefail

ROOT=network-files

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

healthy() {
  sleep 20
  touch ./network-files/run/healthy
}

export PATH=$PWD/bin:$PATH

source ./scripts/nodes-configuration.sh

echo "Clean old state and logs"
./scripts/clean.sh

# Kill all child processes on Ctrl+C
trap 'kill 0' INT

echo "Run"
./scripts/make-babbage.sh
./network-files/run/all.sh &
healthy &

./scripts/update-stake-pools.sh.sh "$SP_NODES_ID"


CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/plutus-transaction.sh
CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/reference-input-transaction.sh
CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/mint-tokens.sh
CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/setup-wallets.sh
CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock ./scripts/mint-handles.sh

touch ./network-files/run/done

wait
