#!/usr/bin/env bash

# This script updates the pools certificates on the network.
set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

SP_NODES=("1" "2" "3")
AMOUNT_PER_WALLET='13500000000000000'

# Pool metadata
METADATA_URLS=("http://file-server/SP1.json" "http://file-server/SP2.json" "http://file-server/SP3.json")
METADATA_HASHES=()

for ((i = 0; i < ${#METADATA_URLS[@]}; ++i)); do
  echo "Calculating hash for metadata at ${METADATA_URLS[$i]}..."

  hash=$(cardano-cli stake-pool metadata-hash --pool-metadata-file <(curl -s -L -k "${METADATA_URLS[$i]}"))

  echo "${hash}"

  METADATA_HASHES[${#METADATA_HASHES[@]}]="${hash}"
done

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
  delegatorPaymentKey=network-files/stake-delegator-keys/payment"${SP_NODES[$i]}".vkey
  delegatorStakingKey=network-files/stake-delegator-keys/staking"${SP_NODES[$i]}".vkey
  delegatorPaymentSKey=network-files/stake-delegator-keys/payment"${SP_NODES[$i]}".skey
  delegatorStakingSKey=network-files/stake-delegator-keys/staking"${SP_NODES[$i]}".skey

  # register delegator stake address
  echo "Registering delegator stake certificate ${SP_NODES[$i]}..."

  paymentAddr=$(cardano-cli address build --payment-verification-key-file "$delegatorPaymentKey" --stake-verification-key-file "$delegatorStakingKey" --testnet-magic 888)
  currentBalance=$(getAddressBalance "$paymentAddr")

  # get pool ID
  poolId=$(cardano-cli stake-pool id --cold-verification-key-file "$coldVKey" --output-format "hex")

  # create pool delegation certificate
  cardano-cli stake-address delegation-certificate \
      --stake-verification-key-file "$delegatorStakingKey" \
      --stake-pool-id "$poolId" \
      --out-file deleg.cert

  utxo=$(cardano-cli query utxo --address "$paymentAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
      --tx-in "$utxo" \
      --tx-out "$paymentAddr"+0 \
      --invalid-hereafter 5000000 \
      --fee 0 \
      --out-file tx.tmp \
      --certificate deleg.cert

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
      --certificate-file deleg.cert \
      --out-file tx.raw

  cardano-cli transaction sign \
      --tx-body-file tx.raw \
      --signing-key-file "$delegatorPaymentSKey" \
      --signing-key-file "$delegatorStakingSKey" \
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
  echo "Update stake pool ${SP_NODES[$i]}..."
  currentBalance=$(getAddressBalance "$paymentAddr")

  cardano-cli stake-pool registration-certificate \
      --cold-verification-key-file "$coldVKey" \
      --vrf-verification-key-file "$vrfKey" \
      --pool-pledge 0 \
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

  utxo=$(cardano-cli query utxo --address "$paymentAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
      --tx-in "$utxo" \
      --tx-out "$paymentAddr"+"$txOut"\
      --invalid-hereafter 500000 \
      --fee 0 \
      --certificate-file pool.cert \
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
      --out-file tx.raw

  cardano-cli transaction sign \
      --tx-body-file tx.raw \
      --signing-key-file "$delegatorPaymentSKey" \
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
