#!/bin/bash
set -x
set -o

environment="$1"

url="https://${environment}.lw.iog.io"

# Construct the environment file content
envFileContent="
# Logger
LOGGER_MIN_SEVERITY=info

# Key management setup - required by getWallet
KEY_MANAGEMENT_PROVIDER=inMemory

# Providers setup - required by getWallet
ASSET_PROVIDER=http
ASSET_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
HANDLE_PROVIDER=http
HANDLE_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4011/\"}'
NETWORK_INFO_PROVIDER=http
NETWORK_INFO_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
REWARDS_PROVIDER=http
REWARDS_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
TX_SUBMIT_PROVIDER=http
TX_SUBMIT_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
UTXO_PROVIDER=http
UTXO_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
STAKE_POOL_PROVIDER=http
STAKE_POOL_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
"

# Write the environment file content to the specified file
echo "$envFileContent" > .env
