#!/usr/bin/env bash


node='./bin/cardano-cli';

# Use GNU sed for MacOS
case $(uname) in
Darwin) sed='gsed' ;;
*) sed='sed' ;;
esac

set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "update-genesis-hashes.sh: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
  sleep 2
done

echo "Calculating genesis hashes"

byronGenesisHash=$($node byron genesis print-genesis-hash --genesis-json byron/genesis.json)
shelleyGenesisHash=$($node genesis hash --genesis shelley/genesis.json)

echo "Byron genesis hash: $byronGenesisHash"
echo "Shelley genesis hash: $shelleyGenesisHash"

$sed -i -E "s/\"ByronGenesisHash\": \".*\"/\"ByronGenesisHash\": \"${byronGenesisHash}\"/"  ../config/network/testnet/cardano-node/config.json 
$sed -i -E "s/\"ShelleyGenesisHash\": \".*\"/\"ShelleyGenesisHash\": \"${shelleyGenesisHash}\"/"  ../config/network/testnet/cardano-node/config.json 

