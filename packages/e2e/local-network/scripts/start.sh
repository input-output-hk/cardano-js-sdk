#!/usr/bin/env bash

set -euo pipefail

ROOT=network-files

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

echo "Clean old state and logs"
./scripts/clean.sh

# Kill all child processes on Ctrl+C
trap 'kill 0' INT

echo "Run"
./scripts/make-babbage.sh
./network-files/run/all.sh &
CARDANO_NODE_SOCKET_PATH=$PWD/network-files/node-spo1/node.sock ./scripts/mint-tokens.sh
wait
