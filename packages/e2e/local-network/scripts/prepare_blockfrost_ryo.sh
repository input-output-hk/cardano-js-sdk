#!/usr/bin/env bash

timeUnix=$(cat network-files/run/system_start)

echo "Update start time in blockfrost genesis file with ${timeUnix}"

mkdir -p ./config/network/blockfrost-ryo/

cp ./templates/blockfrost-ryo/genesis.json ./config/network/blockfrost-ryo/genesis.json
cp ./templates/blockfrost-ryo/byron_genesis.json ./config/network/blockfrost-ryo/byron_genesis.json
cp ./templates/blockfrost-ryo/local-network.yaml ./config/network/blockfrost-ryo/local-network.yaml

sed -i -E "s/\"system_start\": [0-9]+/\"system_start\": ${timeUnix}/" ./config/network/blockfrost-ryo/genesis.json
