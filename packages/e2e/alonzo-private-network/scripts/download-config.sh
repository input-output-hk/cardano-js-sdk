#!/usr/bin/env bash

# This script is for development purpose only. It will download official config files so we can compare them with current config files.

set -euo pipefail

# Source: https://github.com/input-output-hk/cardano-node/releases/tag/1.34.1
BUILD_ID="8111119"

rm -rf dev-config
mkdir -p dev-config
cd dev-config

wget https://hydra.iohk.io/build/${BUILD_ID}/download/1/mainnet-config.json
wget https://hydra.iohk.io/build/${BUILD_ID}/download/1/mainnet-byron-genesis.json
wget https://hydra.iohk.io/build/${BUILD_ID}/download/1/mainnet-shelley-genesis.json
wget https://hydra.iohk.io/build/${BUILD_ID}/download/1/mainnet-alonzo-genesis.json
wget https://hydra.iohk.io/build/${BUILD_ID}/download/1/mainnet-topology.json
