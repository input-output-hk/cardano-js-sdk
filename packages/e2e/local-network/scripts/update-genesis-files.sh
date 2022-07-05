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
timeISO=$($date -d "now + 30 seconds" -u +"%Y-%m-%dT%H:%M:%SZ")
timeUnix=$($date -d "now + 30 seconds" -u +%s)

echo "Update start time in genesis files"
$sed -i -E "s/\"startTime\": [0-9]+/\"startTime\": ${timeUnix}/" byron/genesis.json
$sed -i -E "s/\"systemStart\": \".*\"/\"systemStart\": \"${timeISO}\"/" shelley/genesis.json

cp byron/genesis.json ./config/network/genesis/byron.json
cp byron/genesis.json ./config/network/cardano-node/genesis/byron.json
cp shelley/genesis.json ./config/network/genesis/shelley.json
cp shelley/genesis.json ./config/network/cardano-node/genesis/shelley.json

byronGenesisHash=$(cardano-cli byron genesis print-genesis-hash --genesis-json byron/genesis.json)
shelleyGenesisHash=$(cardano-cli genesis hash --genesis shelley/genesis.json)

echo "Byron genesis hash: $byronGenesisHash"
echo "Shelley genesis hash: $shelleyGenesisHash"

cp ./config/network/config.json  ./config/network/cardano-node/config.json
$sed -i -E "s/\"ByronGenesisHash\": \".*\"/\"ByronGenesisHash\": \"${byronGenesisHash}\"/"  ./config/network/cardano-node/config.json
$sed -i -E "s/\"ShelleyGenesisHash\": \".*\"/\"ShelleyGenesisHash\": \"${shelleyGenesisHash}\"/"  ./config/network/cardano-node/config.json
