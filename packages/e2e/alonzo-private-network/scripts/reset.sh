#!/usr/bin/env bash

set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

# Use GNU sed for MacOS
case $(uname) in
Darwin) sed='gsed' ;;
*) sed='sed' ;;
esac

case $(uname) in
Darwin) date='gdate' ;;
*) date='date' ;;
esac

timeISO=$($date -Iseconds -d "now + 30 seconds")
timeUnix=$($date -d "now + 30 seconds" +%s)

echo "Clean old state and logs"
rm -rf \
  logs \
  node-bft1/db \
  node-bft1/node.log \
  node-bft1/node.sock \
  node-bft2/db \
  node-bft2/node.log \
  node-bft2/node.sock \
  node-pool1/db \
  node-pool1/node.log \
  node-pool1/node.sock \
  sockets/*

mkdir -p sockets

echo "Update start time in genesis files"
$sed -i -E "s/\"startTime\": [0-9]+/\"startTime\": ${timeUnix}/" byron/genesis.json
$sed -i -E "s/\"systemStart\": \".*\"/\"systemStart\": \"${timeISO}\"/" shelley/genesis.json

echo "Update VRF key permission, sometimes GitHub changes these"
chmod 600 \
  node-bft1/shelley/vrf.skey \
  node-bft2/shelley/vrf.skey \
  node-pool1/shelley/vrf.skey

# Kill all child processes on Ctrl+C
trap 'kill 0' INT

echo "Run all nodes"
run/node-bft1.sh &
run/node-bft2.sh &
run/node-pool1.sh &

# Mint test tokens as soon as nodes are ready
CARDANO_NODE_SOCKET_PATH=$PWD/sockets/node-pool1.sock ./scripts/mint-tokens.sh &

wait
