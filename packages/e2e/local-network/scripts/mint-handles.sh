#!/bin/bash

source $(dirname $0)/common.sh

handleNames=("hellohandle" "testhandle" "doublehandle")
handleHexes=("68656c6c6f68616e646c65" "7465737468616e646c65" "646f75626c6568616e646c65")

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
policyid=$(cardano-cli latest transaction policyid --script-file network-files/utxo-keys/minting-policy.json)

cat >network-files/utxo-keys/handles-metadata.json <<EOL
{ "721":
{"${policyid}":
  {
  "${handleNames[0]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[0]}", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []},
  "${handleNames[1]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[1]}", "image": "ipfs://some-hash", "mediaType": "image/jpeg", "files":	[{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []},
  "${handleNames[2]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[2]}", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []},
  "${handleNames[3]}": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "${handleNames[3]}", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}
  }
}}
EOL

echo $policyid >/sdk-ipc/handle_policy_ids
destAddr="addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7"
utxo=$(cardano-cli query utxo --address "$addr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

tokenList="1 ${policyid}.${handleHexes[0]}+1 ${policyid}.${handleHexes[1]}+2 ${policyid}.${handleHexes[2]}"

cardano-cli latest transaction build \
  --change-address "$addr" \
  --tx-in "$utxo" \
  --tx-out "$destAddr"+10000000+"$tokenList" \
  --mint "$tokenList" \
  --mint-script-file network-files/utxo-keys/minting-policy.json \
  --metadata-json-file network-files/utxo-keys/handles-metadata.json \
  --testnet-magic 888 \
  --out-file handle-tx.raw

cardano-cli latest transaction sign \
  --tx-body-file handle-tx.raw \
  --signing-key-file network-files/utxo-keys/payment.skey \
  --testnet-magic 888 \
  --out-file handle-tx.signed

cardano-cli latest transaction submit --testnet-magic 888 --tx-file handle-tx.signed
wait_tx_complete $utxo

# CIP-68 Handle
utxo=$(cardano-cli query utxo --address "$addr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')
# {"constructor": 0,
#   "fields": [
#     {"map": [
#       {"k": {"bytes": "core"}, "v": {"map": [
#         {"k": {"bytes": "og"}, "v": {"int": 0}},
#         {"k": {"bytes": "prefix"}, "v": {"bytes": "24"}},
#         {"k": {"bytes": "version"}, "v": {"int": 0}},
#         {"k": {"bytes": "termsofuse"}, "v": {"bytes": "https://cardanofoundation.org/en/terms-and-conditions/"}},
#         {"k": {"bytes": "handleEncoding"}, "v": {"bytes": "utf-8"}}
#       ]}},
#       {"k": {"bytes": "name"}, "v": {"bytes": "(100)handle68"}},
#       {"k": {"bytes": "image"}, "v": {"bytes": "ipfs://some-hash"}},
#       {"k": {"bytes": "website"}, "v": {"bytes": "https://cardano.org/"}},
#       {"k": {"bytes": "description"}, "v": {"bytes": "The Handle Standard"}},
#       {"k": {"bytes": "augmentations"}, "v": {"list": []}}]
#     },
#     {"int": 1},
#     {"map": []}
#   ]}
cat >network-files/utxo-keys/handles68-datum.json <<EOL
{"constructor": 0,
  "fields": [
    {"map": [
      {"k": {"bytes": "636f7265"}, "v": {"map": [
        {"k": {"bytes": "6f67"}, "v": {"int": 0}},
        {"k": {"bytes": "707265666978"}, "v": {"bytes": "24"}},
        {"k": {"bytes": "76657273696f6e"}, "v": {"int": 0}},
        {"k": {"bytes": "7465726d736f66757365"}, "v": {"bytes": "68747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f"}},
        {"k": {"bytes": "68616e646c65456e636f64696e67"}, "v": {"bytes": "7574662d38"}}
      ]}},
      {"k": {"bytes": "6e616d65"}, "v": {"bytes": "283130302968616e646c653638"}},
      {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f736f6d652d68617368"}},
      {"k": {"bytes": "77656273697465"}, "v": {"bytes": "68747470733a2f2f63617264616e6f2e6f72672f"}},
      {"k": {"bytes": "6465736372697074696f6e"}, "v": {"bytes": "5468652048616e646c65205374616e64617264"}},
      {"k": {"bytes": "6175676d656e746174696f6e73"}, "v": {"list": []}}]
    },
    {"int": 1},
    {"map": []}
  ]}
EOL
#               (222)handle68 -> 283232322968616e646c653638
handle68tokenList="1 ${policyid}.283232322968616e646c653638"
cardano-cli latest transaction build \
  --change-address "$addr" \
  --tx-in "$utxo" \
  --tx-out "$destAddr"+10000000+"$handle68tokenList" \
  --mint "$handle68tokenList" \
  --mint-script-file network-files/utxo-keys/minting-policy.json \
  --tx-out-inline-datum-file network-files/utxo-keys/handles68-datum.json \
  --testnet-magic 888 \
  --out-file handle68-tx.raw

cardano-cli latest transaction sign \
  --tx-body-file handle68-tx.raw \
  --signing-key-file network-files/utxo-keys/payment.skey \
  --testnet-magic 888 \
  --out-file handle68-tx.signed

cardano-cli latest transaction submit --testnet-magic 888 --tx-file handle68-tx.signed
wait_tx_complete $utxo

sync
