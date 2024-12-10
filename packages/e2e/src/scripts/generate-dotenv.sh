#!/bin/bash

set -e

target="${ENVIRONMENT}-${NETWORK}"

case $CLUSTER in
  any)
    environment="${target}"
    ;;
  *)
    environment="${target}.${CLUSTER}"
    ;;
esac

case $NETWORK in
  preprod)
    networkMagic=1
    ;;
  preview)
    networkMagic=2
    ;;
  *)
    echo "${NETWORK}: Unknown network"
    exit 1
    ;;
esac

domain="${environment}.lw.iog.io"
url="https://${domain}/"

# Construct the environment file content
envFileContent="\
LOGGER_MIN_SEVERITY=info

TEST_CLIENT_ASSET_PROVIDER=http
TEST_CLIENT_ASSET_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_CHAIN_HISTORY_PROVIDER=ws
TEST_CLIENT_CHAIN_HISTORY_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_DREP_PROVIDER: 'blockfrost'
# TODO: use blockfrost URL
TEST_CLIENT_DREP_PROVIDER_PARAMS: '{"baseUrl":"http://localhost:3015"}'
TEST_CLIENT_HANDLE_PROVIDER=http
TEST_CLIENT_HANDLE_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_NETWORK_INFO_PROVIDER=ws
TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_REWARDS_PROVIDER=http
TEST_CLIENT_REWARDS_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_TX_SUBMIT_PROVIDER=http
TEST_CLIENT_TX_SUBMIT_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_UTXO_PROVIDER=ws
TEST_CLIENT_UTXO_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_STAKE_POOL_PROVIDER=http
TEST_CLIENT_STAKE_POOL_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
WS_PROVIDER_URL='wss://${domain}/ws'

KEY_MANAGEMENT_PROVIDER=inMemory
KEY_MANAGEMENT_PARAMS='{
  \"bip32Ed25519\": \"Sodium\",
  \"accountIndex\": 0,
  \"chainId\": {
    \"networkId\": 0,
    \"networkMagic\": ${networkMagic}
  },
  \"passphrase\": \"some_passphrase\",
  \"mnemonic\": \"${MNEMONIC}\"
}'"

# Write the environment file content to the specified file
echo "$envFileContent" > .env

# Dump inputs and outputs
echo "
Target environment: ${ENVIRONMENT}
Target network:     ${NETWORK}
Target cluster:     ${CLUSTER}

Result .env:"
cat .env
