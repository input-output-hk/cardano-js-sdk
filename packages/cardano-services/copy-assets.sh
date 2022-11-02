 #!/usr/bin/env bash

# TODO: run this with 'shx' or replace this with some cross-platform script

cp ./package.json ./dist/cjs/original-package.json

cp ./src/Asset/openApi.json ./dist/cjs/Asset/openApi.json
cp ./src/ChainHistory/openApi.json ./dist/cjs/ChainHistory/openApi.json
cp ./src/NetworkInfo/openApi.json ./dist/cjs/NetworkInfo/openApi.json
cp ./src/Rewards/openApi.json ./dist/cjs/Rewards/openApi.json
cp ./src/StakePool/openApi.json ./dist/cjs/StakePool/openApi.json
cp ./src/TxSubmit/openApi.json ./dist/cjs/TxSubmit/openApi.json
cp ./src/Utxo/openApi.json ./dist/cjs/Utxo/openApi.json
cp -R ./src/StakePool/HttpStakePoolMetadata/schemas ./dist/cjs/StakePool/HttpStakePoolMetadata/schemas

# TODO: uncomment when ESM builds are enabled for this package
# cp ./src/StakePool/openApi.json ./dist/esm/StakePool/openApi.json
# cp ./src/TxSubmit/openApi.json ./dist/esm/TxSubmit/openApi.json
# cp ./src/Utxo/openApi.json ./dist/esm/Utxo/openApi.json
# cp ./src/ChainHistory/openApi.json ./dist/esm/ChainHistory/openApi.json
# cp ./src/NetworkInfo/openApi.json ./dist/esm/NetworkInfo/openApi.json
# cp ./src/Rewards/openApi.json ./dist/esm/Rewards/openApi.json

# cp ./package.json ./dist/esm/original-package.json
