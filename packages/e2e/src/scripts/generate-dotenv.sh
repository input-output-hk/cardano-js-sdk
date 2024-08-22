#!/bin/bash

set -e
set -x
set -o

case $2 in
  any)
    environment="$1"
    ;;
  *)
    environment="$1.$2"
    ;;
esac

domain="${environment}.lw.iog.io"
url="https://${domain}/"

# Construct the environment file content
envFileContent="
# Logger
LOGGER_MIN_SEVERITY=info

# Key management setup - required by getWallet
KEY_MANAGEMENT_PROVIDER=inMemory

# Providers setup - required by getWallet
TEST_CLIENT_ASSET_PROVIDER=http
TEST_CLIENT_ASSET_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_CHAIN_HISTORY_PROVIDER=http
TEST_CLIENT_CHAIN_HISTORY_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_HANDLE_PROVIDER=http
TEST_CLIENT_HANDLE_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_NETWORK_INFO_PROVIDER=http
TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_REWARDS_PROVIDER=http
TEST_CLIENT_REWARDS_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_TX_SUBMIT_PROVIDER=http
TEST_CLIENT_TX_SUBMIT_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_UTXO_PROVIDER=http
TEST_CLIENT_UTXO_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
TEST_CLIENT_STAKE_POOL_PROVIDER=http
TEST_CLIENT_STAKE_POOL_PROVIDER_PARAMS='{\"baseUrl\":\"${url}\"}'
WS_PROVIDER_URL='wss://${domain}/ws'
"

# Write the environment file content to the specified file
echo "$envFileContent" > .env
