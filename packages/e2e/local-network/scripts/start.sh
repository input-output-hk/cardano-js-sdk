#!/usr/bin/env bash

set -euo pipefail

ROOT=network-files

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

healthy() {
  # For some unknown reasons, if started before half of first epoch, db-sync doesn't sync
  while [ `cardano-cli query tip --testnet-magic 888 | jq .slot` -lt 500 ] ; do sleep 1 ; done
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
./scripts/prepare_blockfrost_ryo.sh
./network-files/run/all.sh &

if [ -d /sdk-ipc ] ; then cp -a config/network /sdk-ipc/config ; fi

export CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-sp1/node.sock

while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "start.sh: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
  sleep 1
done

while [ `cardano-cli query tip --testnet-magic 888 | jq .block` == null ] ; do
  echo "start.sh: WAIT_FOR_TIP: Waiting for a tip..."
  sleep 1
done


./scripts/setup-new-delegator-keys.sh
./scripts/update-stake-pools.sh.sh "$SP_NODES_ID"

./scripts/plutus-transaction.sh
./scripts/reference-input-transaction.sh
./scripts/mint-tokens.sh
./scripts/setup-wallets.sh
./scripts/mint-handles.sh

touch ./network-files/run/done

healthy &

wait
