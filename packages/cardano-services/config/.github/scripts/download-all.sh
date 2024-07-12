#!/bin/bash

# Download configuration files from a nominated URL for a nominated network

CARDANO_CONFIG_URL=$1
CARDANO_NETWORK=$2

mkdir -p \
  network/$CARDANO_NETWORK/cardano-node \
  network/$CARDANO_NETWORK/genesis \
  network/$CARDANO_NETWORK/cardano-db-sync \
  network/$CARDANO_NETWORK/cardano-submit-api

wget -q $CARDANO_CONFIG_URL/$CARDANO_NETWORK/topology.json -O network/$CARDANO_NETWORK/cardano-node/topology.json
wget -qO- $CARDANO_CONFIG_URL/$CARDANO_NETWORK/config.json \
  | jq '.ByronGenesisFile = "../genesis/byron.json" | .ShelleyGenesisFile = "../genesis/shelley.json" | .AlonzoGenesisFile = "../genesis/alonzo.json"' \
  | jq '.' > network/$CARDANO_NETWORK/cardano-node/config.json
wget -qO- $CARDANO_CONFIG_URL/$CARDANO_NETWORK/db-sync-config.json \
  | jq '.NodeConfigFile = "../cardano-node/config.json"' \
  | jq '.' > network/$CARDANO_NETWORK/cardano-db-sync/config.json
wget -q $CARDANO_CONFIG_URL/$CARDANO_NETWORK/submit-api-config.json -O network/$CARDANO_NETWORK/cardano-submit-api/config.json


# Genesis
wget -q $CARDANO_CONFIG_URL/$CARDANO_NETWORK/byron-genesis.json -O network/$CARDANO_NETWORK/genesis/byron.json
wget -q $CARDANO_CONFIG_URL/$CARDANO_NETWORK/shelley-genesis.json -O network/$CARDANO_NETWORK/genesis/shelley.json
wget -q $CARDANO_CONFIG_URL/$CARDANO_NETWORK/alonzo-genesis.json -O network/$CARDANO_NETWORK/genesis/alonzo.json
if wget --spider $CARDANO_CONFIG_URL/$CARDANO_NETWORK/conway-genesis.json 2>/dev/null; then
  wget -q $CARDANO_CONFIG_URL/$CARDANO_NETWORK/conway-genesis.json -O network/$CARDANO_NETWORK/genesis/conway.json
  mv network/$CARDANO_NETWORK/cardano-node/config.json network/$CARDANO_NETWORK/cardano-node/config.json.tmp
  cat network/$CARDANO_NETWORK/cardano-node/config.json.tmp \
  | jq '.ConwayGenesisFile = "../genesis/conway.json"' \
  | jq '.' > network/$CARDANO_NETWORK/cardano-node/config.json
  rm network/$CARDANO_NETWORK/cardano-node/config.json.tmp
fi

