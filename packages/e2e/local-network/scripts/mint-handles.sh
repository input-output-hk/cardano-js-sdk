#!/bin/bash

handleNames=("HelloHandle" "TestHandle" "DoubleHandle")
handleHexes=("48656c6c6f48616e646c65" "5465737448616e646c65" "446f75626c6548616e646c65")

cat >network-files/utxo-keys/minting-policy.json <<EOL
{
  "keyHash": "$(cardano-cli address key-hash --payment-verification-key-file network-files/utxo-keys/utxo1.vkey)",
  "type": "sig"
}
EOL

# Generate the policy ID from the script file and save it
policyid=$(cardano-cli transaction policyid --script-file network-files/utxo-keys/minting-policy.json)

cat >network-files/utxo-keys/handles-metadata.json <<EOL
{ "721":
{"${policyid}":
  {
  "${handleNames[0]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[0]}", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []},
  "${handleNames[1]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[1]}", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []},
  "${handleNames[2]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[2]}", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []},
  "${handleNames[3]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[3]}", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}
  }
}}
EOL

echo $policyid > /sdk-ipc/handle_policy_ids

addr=$(cardano-cli address build --payment-verification-key-file network-files/utxo-keys/utxo1.vkey --testnet-magic 888)
faucetAddr="addr_test1qqen0wpmhg7fhkus45lyv4wju26cecgu6avplrnm6dgvuk6qel5hu3u3q0fht53ly97yx95hkt56j37ch07pesf6s4pqh5gd4e"
utxo=$(cardano-cli query utxo --address "$addr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

tokenList="1 ${policyid}.${handleHexes[0]}+1 ${policyid}.${handleHexes[1]}+2 ${policyid}.${handleHexes[2]}"

cardano-cli transaction build \
  --babbage-era \
  --change-address "$addr" \
  --tx-in "$utxo" \
  --tx-out "$faucetAddr"+10000000+"$tokenList" \
  --mint "$tokenList" \
  --mint-script-file network-files/utxo-keys/minting-policy.json \
  --metadata-json-file network-files/utxo-keys/handles-metadata.json \
  --testnet-magic 888 \
  --out-file handle-tx.raw

cardano-cli transaction sign \
  --tx-body-file handle-tx.raw \
  --signing-key-file network-files/utxo-keys/utxo1.skey \
  --testnet-magic 888 \
  --out-file handle-tx.signed

cardano-cli transaction submit --testnet-magic 888 --tx-file handle-tx.signed
