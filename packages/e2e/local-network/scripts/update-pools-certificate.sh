#!/usr/bin/env bash

# This script updates the pools certificates on the network.
set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

# Pool metadata
METADATA_URLS=("https://pools.iohk.io/IOG1.json" "https://pools.iohk.io/IOG2.json" "https://pools.iohk.io/IOG3.json")
METADATA_HASHES=("22cf1de98f4cf4ce61bef2c6bc99890cb39f1452f5143189ce3a69ad70fcde72" "04faac1dce6c68b6bdf406eb261fbc6f57ce0baa9ab039d8e3bb1de8f903f092" "47d5ad9a718bfd40892ab89eb46b34ef2b1ebce9ebba6f5410a1ab96284771ed")

SP_NODES=("1" "2" "3")
AMOUNT_PER_WALLET='1000000000'

clean() {
  rm -rf wallets-tx.raw wallets-tx.signed fullUtxo.out balance.out params.json stake.cert pool.cert deleg.cert tx.tmp tx.raw tx.signed
}

getAddressBalance() {
  cardano-cli query utxo \
      --address "$1" \
      --testnet-magic 888 > fullUtxo.out

  tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

  total_balance=0
  while read -r utxo; do
      utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
      total_balance=$(("$total_balance"+"$utxo_balance"))
  done < balance.out

  echo ${total_balance}
}

trap clean EXIT

while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "update-pools-certificate.sh: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
  sleep 2
done

# get the protocol parameters
cardano-cli query protocol-parameters --testnet-magic 888 --out-file params.json

# iterate over all the pools
for ((i = 0; i < ${#SP_NODES[@]}; ++i)); do

  stakeVKey=network-files/pools/staking-reward"${SP_NODES[$i]}".vkey
  stakeKey=network-files/pools/staking-reward"${SP_NODES[$i]}".skey
  coldVKey=network-files/pools/cold"${SP_NODES[$i]}".vkey
  coldKey=network-files/pools/cold"${SP_NODES[$i]}".skey
  vrfKey=network-files/pools/vrf"${SP_NODES[$i]}".vkey
  genesisKey=network-files/utxo-keys/utxo3.vkey

  # create staking payment address
  paymentAddr=$(cardano-cli address build --payment-verification-key-file "$genesisKey" --stake-verification-key-file "$stakeVKey" --testnet-magic 888)

  genesisAddr=$(cardano-cli address build --payment-verification-key-file "$genesisKey" --testnet-magic 888)
  utxo=$(cardano-cli query utxo --address "$genesisAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  # funding staking address
  echo "Funding staking address ${SP_NODES[$i]}..."

  currentBalance=$(getAddressBalance "$paymentAddr")

  cardano-cli transaction build \
    --babbage-era \
    --change-address "$genesisAddr" \
    --tx-in "$utxo" \
    --tx-out "$paymentAddr"+"$AMOUNT_PER_WALLET" \
    --testnet-magic 888 \
    --out-file wallets-tx.raw

  cardano-cli transaction sign \
    --tx-body-file wallets-tx.raw \
    --signing-key-file network-files/utxo-keys/utxo3.skey \
    --testnet-magic 888 \
    --out-file wallets-tx.signed

  cardano-cli transaction submit --testnet-magic 888 --tx-file wallets-tx.signed

  updatedBalance=$(getAddressBalance "$paymentAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]
  do
    updatedBalance=$(getAddressBalance "$paymentAddr")
    sleep 1
  done

  # register staking address
  echo "Registering stake certificate ${SP_NODES[$i]}..."

  currentBalance=$(getAddressBalance "$paymentAddr")

  cardano-cli stake-address registration-certificate \
      --stake-verification-key-file "$stakeVKey" \
      --out-file stake.cert

  utxo=$(cardano-cli query utxo --address "$paymentAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
      --tx-in "$utxo" \
      --tx-out "$paymentAddr"+0 \
      --invalid-hereafter 5000000 \
      --fee 0 \
      --out-file tx.tmp \
      --certificate stake.cert

  fee1=$(cardano-cli transaction calculate-min-fee \
      --tx-body-file tx.tmp \
      --tx-in-count 1 \
      --tx-out-count 1 \
      --testnet-magic 888 \
      --witness-count 2 \
      --byron-witness-count 0 \
      --protocol-params-file ./params.json | awk '{ print $1 }')

  txOut=$((AMOUNT_PER_WALLET - fee1))

  cardano-cli transaction build-raw \
      --tx-in "$utxo" \
      --tx-out "$paymentAddr"+"$txOut" \
      --invalid-hereafter 5000000 \
      --fee "$fee1" \
      --certificate-file stake.cert \
      --out-file tx.raw

  cardano-cli transaction sign \
      --tx-body-file tx.raw \
      --signing-key-file network-files/utxo-keys/utxo3.skey \
      --signing-key-file "$stakeKey" \
      --testnet-magic 888 \
      --out-file tx.signed

  cardano-cli transaction submit \
      --tx-file tx.signed \
      --testnet-magic 888

  updatedBalance=$(getAddressBalance "$paymentAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]
  do
    updatedBalance=$(getAddressBalance "$paymentAddr")
    sleep 1
  done

  # creating certs
  echo "Registering stake pool ${SP_NODES[$i]}..."
  currentBalance=$(getAddressBalance "$paymentAddr")

  cardano-cli stake-pool registration-certificate \
      --cold-verification-key-file "$coldVKey" \
      --vrf-verification-key-file "$vrfKey" \
      --pool-pledge 500000000 \
      --pool-cost 345000000 \
      --pool-margin 0.15 \
      --pool-reward-account-verification-key-file "$stakeVKey" \
      --pool-owner-stake-verification-key-file "$stakeVKey" \
      --testnet-magic 888 \
      --pool-relay-ipv4 127.0.0.1 \
      --pool-relay-port 3001 \
      --metadata-url "${METADATA_URLS[$i]}" \
      --metadata-hash "${METADATA_HASHES[$i]}" \
      --out-file pool.cert

  cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file "$stakeVKey" \
    --cold-verification-key-file "$coldVKey" \
    --out-file deleg.cert

  utxo=$(cardano-cli query utxo --address "$paymentAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
      --tx-in "$utxo" \
      --tx-out "$paymentAddr"+"$txOut"\
      --invalid-hereafter 500000 \
      --fee 0 \
      --certificate-file pool.cert \
      --certificate-file deleg.cert \
      --out-file tx.tmp

  fee2=$(cardano-cli transaction calculate-min-fee \
      --tx-body-file tx.tmp \
      --tx-in-count 1 \
      --tx-out-count 1 \
      --testnet-magic 888 \
      --witness-count 3 \
      --byron-witness-count 0 \
      --protocol-params-file ./params.json | awk '{ print $1 }')

  txOut=$((AMOUNT_PER_WALLET - fee1 - fee2))

  cardano-cli transaction build-raw \
      --tx-in "$utxo" \
      --tx-out "$paymentAddr"+"$txOut"\
      --invalid-hereafter 500000 \
      --fee "$fee2" \
      --certificate-file pool.cert \
      --certificate-file deleg.cert \
      --out-file tx.raw

  cardano-cli transaction sign \
      --tx-body-file tx.raw \
      --signing-key-file network-files/utxo-keys/utxo3.skey \
      --signing-key-file "$coldKey" \
      --signing-key-file "$stakeKey" \
      --testnet-magic 888 \
      --out-file tx.signed

  cardano-cli transaction submit \
      --tx-file tx.signed \
      --testnet-magic 888

  updatedBalance=$(getAddressBalance "$paymentAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]
  do
    updatedBalance=$(getAddressBalance "$paymentAddr")
    sleep 1
  done

  echo "Done!"
done
