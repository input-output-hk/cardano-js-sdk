#!/usr/bin/env bash

# This script mint native tokens to genesis address
set -euo pipefail

source $(dirname $0)/common.sh

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH
TOKENS=(744d494e 74425443 74455448)
AMOUNT='13500000000000000'

clean() {
  rm -rf tx.raw tx.signed
  rm -rf shelley
}

trap clean EXIT

while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "mint-tokens.sh: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
  sleep 2
done

echo "Create Mary-era minting policy"
cat >network-files/utxo-keys/minting-policy.json <<EOL
{
  "keyHash": "$(cardano-cli address key-hash --payment-verification-key-file network-files/utxo-keys/utxo1.vkey)",
  "type": "sig"
}
EOL

currencySymbol=$(cardano-cli latest transaction policyid --script-file network-files/utxo-keys/minting-policy.json)
addr=$(cardano-cli address build --payment-verification-key-file network-files/utxo-keys/utxo1.vkey --testnet-magic 888)
destAddr="addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7"

# Spend the first UTxO
utxo=$(cardano-cli query utxo --address "$addr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

# Build token list. We start with a token with empty asset name as this is often an edge case for devs.
tokenList="${AMOUNT} ${currencySymbol}"
for i in "${!TOKENS[@]}"; do
  tokenList="${tokenList}+${AMOUNT} ${currencySymbol}.${TOKENS[i]}"
done

cardano-cli latest transaction build \
  --change-address "$addr" \
  --tx-in "$utxo" \
  --tx-out "$destAddr"+10000000+"$tokenList" \
  --mint "$tokenList" \
  --mint-script-file network-files/utxo-keys/minting-policy.json \
  --testnet-magic 888 \
  --out-file tx.raw

cardano-cli latest transaction sign \
  --tx-body-file tx.raw \
  --signing-key-file network-files/utxo-keys/utxo1.skey \
  --testnet-magic 888 \
  --out-file tx.signed

cardano-cli latest transaction submit --testnet-magic 888 --tx-file tx.signed
wait_tx_complete $utxo
