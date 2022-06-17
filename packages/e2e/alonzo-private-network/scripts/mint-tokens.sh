#!/usr/bin/env bash

# This script mint native tokens to genesis address
set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH
TOKENS=(744d494e 74425443 74455448)
AMOUNT='45000000000000000'

clean() {
  rm -rf tx.raw tx.signed
}
trap clean EXIT

while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "mint-tokens.sh: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
  sleep 2
done

echo "Create Mary-era minting policy"
cat >shelley/utxo-keys/minting-policy.json <<EOL
{
  "keyHash": "$(cardano-cli address key-hash --payment-verification-key-file shelley/utxo-keys/utxo1.vkey)",
  "type": "sig"
}
EOL

currencySymbol=$(cardano-cli transaction policyid --script-file shelley/utxo-keys/minting-policy.json)
addr=$(cardano-cli address build --payment-verification-key-file shelley/utxo-keys/utxo1.vkey --testnet-magic 42)
# Spend the first UTxO
utxo=$(cardano-cli query utxo --address "$addr" --testnet-magic 42 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

# Build token list. We start with a token with empty asset name as this is often an edge case for devs.
tokenList="${AMOUNT} ${currencySymbol}"
for i in "${!TOKENS[@]}"; do
  tokenList="${tokenList}+${AMOUNT} ${currencySymbol}.${TOKENS[i]}"
done

cardano-cli transaction build \
  --alonzo-era \
  --change-address "$addr" \
  --tx-in "$utxo" \
  --tx-out "$addr"+10000000+"$tokenList" \
  --mint "$tokenList" \
  --mint-script-file shelley/utxo-keys/minting-policy.json \
  --testnet-magic 42 \
  --out-file tx.raw

cardano-cli transaction sign \
  --tx-body-file tx.raw \
  --signing-key-file shelley/utxo-keys/utxo1.skey \
  --testnet-magic 42 \
  --out-file tx.signed

cardano-cli transaction submit --testnet-magic 42 --tx-file tx.signed
