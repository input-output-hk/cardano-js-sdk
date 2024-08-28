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
TEST_CLIENT_ASSET_PROVIDER=http
TEST_CLIENT_ASSET_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
TEST_CLIENT_HANDLE_PROVIDER=http
TEST_CLIENT_HANDLE_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4011/\"}'
TEST_CLIENT_NETWORK_INFO_PROVIDER=http
TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
TEST_CLIENT_REWARDS_PROVIDER=http
TEST_CLIENT_REWARDS_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
TEST_CLIENT_TX_SUBMIT_PROVIDER=http
TEST_CLIENT_TX_SUBMIT_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
TEST_CLIENT_UTXO_PROVIDER=http
TEST_CLIENT_UTXO_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
TEST_CLIENT_STAKE_POOL_PROVIDER=http
TEST_CLIENT_STAKE_POOL_PROVIDER_PARAMS='{\"baseUrl\":\"$url:4000/\"}'
"

# Write the environment file content to the specified file
echo "$envFileContent" > .env
