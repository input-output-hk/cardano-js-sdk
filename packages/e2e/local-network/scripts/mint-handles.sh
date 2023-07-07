#!/bin/bash

handleNames=("HelloHandle" "TestHandle" "DoubleHandle")
handleHexes=("48656c6c6f48616e646c65" "5465737448616e646c65" "446f75626c6548616e646c65")

# addr, payment.skey and payment.vkey are generated from mnemonic
# vacant violin soft weird deliver render brief always monitor general maid smart jelly core drastic erode echo there clump dizzy card filter option defense
# addr funded in setup-wallets.sh
# to update keys for new mnemonic use mnemonic_keys.sh
addr="addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7"
cat >network-files/utxo-keys/payment.skey <<EOL
{
    "type": "PaymentExtendedSigningKeyShelley_ed25519_bip32",
    "description": "",
    "cborHex": "5880101c0d1805fb4c54f3a9f2859de2f9665c66fdef51236d86c333469f127582500046245356898f5d18eb3999670b9d2ee7fe83d21127317bb2f59d64aafcf515368cf6a11ac7e29917568a366af62a596cb9cde8174bfe7f6e88393ecdb1dcc621141aa9593f01bd18d4694541b40a6442d81845f458c0002fb2f12c3d205cf2"
}
EOL

cat >network-files/utxo-keys/payment.vkey <<EOL
{
    "type": "PaymentVerificationKeyShelley_ed25519",
    "description": "",
    "cborHex": "5820368cf6a11ac7e29917568a366af62a596cb9cde8174bfe7f6e88393ecdb1dcc6"
}
EOL

cat >network-files/utxo-keys/minting-policy.json <<EOL
{
  "keyHash": "$(cardano-cli address key-hash --payment-verification-key-file network-files/utxo-keys/payment.vkey)",
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
destAddr="addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7"
utxo=$(cardano-cli query utxo --address "$addr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

tokenList="1 ${policyid}.${handleHexes[0]}+1 ${policyid}.${handleHexes[1]}+2 ${policyid}.${handleHexes[2]}"

cardano-cli transaction build \
  --babbage-era \
  --change-address "$addr" \
  --tx-in "$utxo" \
  --tx-out "$destAddr"+10000000+"$tokenList" \
  --mint "$tokenList" \
  --mint-script-file network-files/utxo-keys/minting-policy.json \
  --metadata-json-file network-files/utxo-keys/handles-metadata.json \
  --testnet-magic 888 \
  --out-file handle-tx.raw

cardano-cli transaction sign \
  --tx-body-file handle-tx.raw \
  --signing-key-file network-files/utxo-keys/payment.skey \
  --testnet-magic 888 \
  --out-file handle-tx.signed

cardano-cli transaction submit --testnet-magic 888 --tx-file handle-tx.signed
