#!/usr/bin/env bash

# This script updates the pools certificates on the network.
set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

SP_NODE_ID="$1"

mkdir ${SP_NODE_ID}

clean() {
  rm -rf ${SP_NODE_ID}
}

getAddressBalance() {
  cardano-cli query utxo \
    --address "$1" \
    --testnet-magic 888 > ${SP_NODE_ID}/fullUtxo.out

  tail -n +3 ${SP_NODE_ID}/fullUtxo.out | sort -k3 -nr > ${SP_NODE_ID}/balance.out

  total_balance=0
  while read -r utxo; do
    utxo_balance=$(awk '{ print $3 }' <<<"${utxo}")
    total_balance=$(("$total_balance" + "$utxo_balance"))
  done < ${SP_NODE_ID}/balance.out

  echo ${total_balance}
}

trap clean EXIT

updatePool() {
  # pool parameters
  SP_NODE_ID="$1"
  POOL_PLEDGE="$2"
  POOL_OWNER_STAKE="$3"
  POOL_COST="$4"
  POOL_MARGIN="$5"
  METADATA_URL=""
  METADATA_HASH=""

  while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
    echo "update-node-sp${SP_NODE_ID}.sh: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
    sleep 2
  done

  # Pool metadata hash (only compute it if a metadata url has been given)
  if [ -n "$6" ]; then
    METADATA_URL="$6"
    METADATA_HASH=$(cardano-cli stake-pool metadata-hash --pool-metadata-file <(curl -s -L -k "${METADATA_URL}"))
  fi

  # get the protocol parameters
  cardano-cli query protocol-parameters --testnet-magic 888 --out-file ${SP_NODE_ID}/params.json

  genesisVKey=network-files/utxo-keys/utxo${SP_NODE_ID}.vkey
  genesisSKey=network-files/utxo-keys/utxo${SP_NODE_ID}.skey
  genesisAddr=$(cardano-cli address build --payment-verification-key-file "$genesisVKey" --testnet-magic 888)

  stakeVKey=network-files/pools/staking-reward"${SP_NODE_ID}".vkey
  stakeKey=network-files/pools/staking-reward"${SP_NODE_ID}".skey
  coldVKey=network-files/pools/cold"${SP_NODE_ID}".vkey
  coldKey=network-files/pools/cold"${SP_NODE_ID}".skey
  vrfKey=network-files/pools/vrf"${SP_NODE_ID}".vkey
  delegatorPaymentKey=network-files/stake-delegator-keys/payment"${SP_NODE_ID}".vkey
  delegatorStakeKey=network-files/stake-delegator-keys/staking"${SP_NODE_ID}".vkey
  delegatorPaymentSKey=network-files/stake-delegator-keys/payment"${SP_NODE_ID}".skey
  delegatorStakeSKey=network-files/stake-delegator-keys/staking"${SP_NODE_ID}".skey

  POOL_ID=$(cardano-cli stake-pool id --cold-verification-key-file "$coldVKey" --output-format "hex")

  # funding pool owner stake address
  stakeAddr=$(cardano-cli address build --payment-verification-key-file "$genesisVKey" --stake-verification-key-file "$stakeVKey" --testnet-magic 888)
  currentBalance=$(getAddressBalance "$stakeAddr")
  utxo=$(cardano-cli query utxo --address "$genesisAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build \
    --babbage-era \
    --change-address "$genesisAddr" \
    --tx-in "$utxo" \
    --tx-out "$stakeAddr"+"$POOL_OWNER_STAKE" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/wallets-tx.raw 2>&1

  cardano-cli transaction sign \
    --tx-body-file ${SP_NODE_ID}/wallets-tx.raw \
    --signing-key-file "$genesisSKey" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/wallets-tx.signed 2>&1

  cardano-cli transaction submit --testnet-magic 888 --tx-file ${SP_NODE_ID}/wallets-tx.signed 2>&1

  updatedBalance=$(getAddressBalance "$stakeAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]; do
    updatedBalance=$(getAddressBalance "$stakeAddr")
    sleep 1
  done

  # register pool owner stake address
  currentBalance=$(getAddressBalance "$genesisAddr")
  cardano-cli stake-address registration-certificate \
    --stake-verification-key-file "$stakeVKey" \
    --out-file ${SP_NODE_ID}/pool-owner-registration.cert

  utxo=$(cardano-cli query utxo --address "$genesisAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$genesisAddr"+0 \
    --invalid-hereafter 5000000 \
    --fee 0 \
    --out-file ${SP_NODE_ID}/tx.tmp \
    --certificate ${SP_NODE_ID}/pool-owner-registration.cert

  fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${SP_NODE_ID}/tx.tmp \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --testnet-magic 888 \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file ${SP_NODE_ID}/params.json | awk '{ print $1 }')

  initialBalance=$(getAddressBalance "$genesisAddr")
  txOut=$((initialBalance - fee))

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$genesisAddr"+"$txOut" \
    --invalid-hereafter 5000000 \
    --fee "$fee" \
    --certificate ${SP_NODE_ID}/pool-owner-registration.cert \
    --out-file ${SP_NODE_ID}/tx.raw

  cardano-cli transaction sign \
    --tx-body-file ${SP_NODE_ID}/tx.raw \
    --signing-key-file "$genesisSKey" \
    --signing-key-file "$stakeKey" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/tx.signed

  cardano-cli transaction submit \
    --tx-file ${SP_NODE_ID}/tx.signed \
    --testnet-magic 888

  updatedBalance=$(getAddressBalance "$genesisAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]; do
    updatedBalance=$(getAddressBalance "$genesisAddr")
    sleep 1
  done

  # delegating pool owner stake
  currentBalance=$(getAddressBalance "$genesisAddr")
  cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file "$stakeVKey" \
    --cold-verification-key-file "$coldVKey" \
    --out-file ${SP_NODE_ID}/pool-owner-delegation.cert

  utxo=$(cardano-cli query utxo --address "$genesisAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$genesisAddr"+0 \
    --invalid-hereafter 5000000 \
    --fee 0 \
    --out-file ${SP_NODE_ID}/tx.tmp \
    --certificate ${SP_NODE_ID}/pool-owner-delegation.cert

  fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${SP_NODE_ID}/tx.tmp \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --testnet-magic 888 \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file ${SP_NODE_ID}/params.json | awk '{ print $1 }')

  initialBalance=$(getAddressBalance "$genesisAddr")
  txOut=$((initialBalance - fee))

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$genesisAddr"+"$txOut" \
    --invalid-hereafter 5000000 \
    --fee "$fee" \
    --certificate ${SP_NODE_ID}/pool-owner-delegation.cert \
    --out-file ${SP_NODE_ID}/tx.raw

  cardano-cli transaction sign \
    --tx-body-file ${SP_NODE_ID}/tx.raw \
    --signing-key-file "$genesisSKey" \
    --signing-key-file "$stakeKey" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/tx.signed

  cardano-cli transaction submit \
    --tx-file ${SP_NODE_ID}/tx.signed \
    --testnet-magic 888

  updatedBalance=$(getAddressBalance "$genesisAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]; do
    updatedBalance=$(getAddressBalance "$genesisAddr")
    sleep 1
  done

  # register delegator stake address
  echo "Registering delegator stake certificate ${SP_NODE_ID}..."

  paymentAddr=$(cardano-cli address build --payment-verification-key-file "$delegatorPaymentKey" --stake-verification-key-file "$delegatorStakeKey" --testnet-magic 888)
  currentBalance=$(getAddressBalance "$paymentAddr")

  # create pool delegation certificate
  cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file "$delegatorStakeKey" \
    --stake-pool-id "$POOL_ID" \
    --out-file ${SP_NODE_ID}/deleg.cert

  utxo=$(cardano-cli query utxo --address "$paymentAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$paymentAddr"+0 \
    --invalid-hereafter 5000000 \
    --fee 0 \
    --out-file ${SP_NODE_ID}/tx.tmp \
    --certificate ${SP_NODE_ID}/deleg.cert

  fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${SP_NODE_ID}/tx.tmp \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --testnet-magic 888 \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file ${SP_NODE_ID}/params.json | awk '{ print $1 }')

  initialBalance=$(getAddressBalance "$paymentAddr")
  txOut=$((initialBalance - fee))

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$paymentAddr"+"$txOut" \
    --invalid-hereafter 5000000 \
    --fee "$fee" \
    --certificate-file ${SP_NODE_ID}/deleg.cert \
    --out-file ${SP_NODE_ID}/tx.raw

  cardano-cli transaction sign \
    --tx-body-file ${SP_NODE_ID}/tx.raw \
    --signing-key-file "$delegatorPaymentSKey" \
    --signing-key-file "$delegatorStakeSKey" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/tx.signed

  cardano-cli transaction submit \
    --tx-file ${SP_NODE_ID}/tx.signed \
    --testnet-magic 888

  updatedBalance=$(getAddressBalance "$paymentAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]; do
    updatedBalance=$(getAddressBalance "$paymentAddr")
    sleep 1
  done

  # creating certs
  echo "Update stake pool ${SP_NODE_ID}..."
  currentBalance=$(getAddressBalance "$paymentAddr")

  # Only add metadata if given.
  if [ -n "$6" ]; then
    cardano-cli stake-pool registration-certificate \
      --cold-verification-key-file "$coldVKey" \
      --vrf-verification-key-file "$vrfKey" \
      --pool-pledge "$POOL_PLEDGE" \
      --pool-cost "$POOL_COST" \
      --pool-margin "$POOL_MARGIN" \
      --pool-reward-account-verification-key-file "$stakeVKey" \
      --pool-owner-stake-verification-key-file "$stakeVKey" \
      --testnet-magic 888 \
      --pool-relay-ipv4 127.0.0.1 \
      --pool-relay-port 300"$SP_NODE_ID" \
      --metadata-url "${METADATA_URL}" \
      --metadata-hash "${METADATA_HASH}" \
      --out-file ${SP_NODE_ID}/pool.cert
  else
    cardano-cli stake-pool registration-certificate \
      --cold-verification-key-file "$coldVKey" \
      --vrf-verification-key-file "$vrfKey" \
      --pool-pledge "$POOL_PLEDGE" \
      --pool-cost "$POOL_COST" \
      --pool-margin "$POOL_MARGIN" \
      --pool-reward-account-verification-key-file "$stakeVKey" \
      --pool-owner-stake-verification-key-file "$stakeVKey" \
      --testnet-magic 888 \
      --pool-relay-ipv4 127.0.0.1 \
      --pool-relay-port 300"$SP_NODE_ID" \
      --out-file ${SP_NODE_ID}/pool.cert
  fi

  utxo=$(cardano-cli query utxo --address "$paymentAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$paymentAddr"+"$txOut" \
    --invalid-hereafter 500000 \
    --fee 0 \
    --certificate-file ${SP_NODE_ID}/pool.cert \
    --out-file ${SP_NODE_ID}/tx.tmp

  fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${SP_NODE_ID}/tx.tmp \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --testnet-magic 888 \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file ${SP_NODE_ID}/params.json | awk '{ print $1 }')

  initialBalance=$(getAddressBalance "$paymentAddr")
  txOut=$((initialBalance - fee))

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$paymentAddr"+"$txOut" \
    --invalid-hereafter 500000 \
    --fee "$fee" \
    --certificate-file ${SP_NODE_ID}/pool.cert \
    --out-file ${SP_NODE_ID}/tx.raw

  cardano-cli transaction sign \
    --tx-body-file ${SP_NODE_ID}/tx.raw \
    --signing-key-file "$delegatorPaymentSKey" \
    --signing-key-file "$coldKey" \
    --signing-key-file "$stakeKey" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/tx.signed

  cardano-cli transaction submit \
    --tx-file ${SP_NODE_ID}/tx.signed \
    --testnet-magic 888

  updatedBalance=$(getAddressBalance "$paymentAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]; do
    updatedBalance=$(getAddressBalance "$paymentAddr")
    sleep 1
  done

  echo "Done!"
}

deregisterPool() {
  # pool parameters
  SP_NODE_ID="$1"
  RETIRING_EPOCH="$2"

  while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
    echo "deregister pool ${SP_NODE_ID}: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
    sleep 2
  done

  # get the protocol parameters
  cardano-cli query protocol-parameters --testnet-magic 888 --out-file ${SP_NODE_ID}/params.json

  genesisVKey=network-files/utxo-keys/utxo${SP_NODE_ID}.vkey
  genesisSKey=network-files/utxo-keys/utxo${SP_NODE_ID}.skey
  genesisAddr=$(cardano-cli address build --payment-verification-key-file "$genesisVKey" --testnet-magic 888)
  stakeKey=network-files/pools/staking-reward"${SP_NODE_ID}".skey
  coldVKey=network-files/pools/cold"${SP_NODE_ID}".vkey
  coldKey=network-files/pools/cold"${SP_NODE_ID}".skey
  delegatorPaymentKey=network-files/stake-delegator-keys/payment"${SP_NODE_ID}".vkey
  delegatorStakeKey=network-files/stake-delegator-keys/staking"${SP_NODE_ID}".vkey
  delegatorPaymentSKey=network-files/stake-delegator-keys/payment"${SP_NODE_ID}".skey
  delegatorStakeSKey=network-files/stake-delegator-keys/staking"${SP_NODE_ID}".skey

  # We are going to redelegate this stake to dbSync can index it properly.
  echo "Registering delegator stake certificate ${SP_NODE_ID}..."

  paymentAddr=$(cardano-cli address build --payment-verification-key-file "$delegatorPaymentKey" --stake-verification-key-file "$delegatorStakeKey" --testnet-magic 888)
  currentBalance=$(getAddressBalance "$paymentAddr")

  POOL_ID=$(cardano-cli stake-pool id --cold-verification-key-file "$coldVKey" --output-format "hex")

  # create pool delegation certificate
  cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file "$delegatorStakeKey" \
    --stake-pool-id "$POOL_ID" \
    --out-file ${SP_NODE_ID}/deleg.cert

  utxo=$(cardano-cli query utxo --address "$paymentAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$paymentAddr"+0 \
    --invalid-hereafter 5000000 \
    --fee 0 \
    --out-file ${SP_NODE_ID}/tx.tmp \
    --certificate ${SP_NODE_ID}/deleg.cert

  fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${SP_NODE_ID}/tx.tmp \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --testnet-magic 888 \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file ${SP_NODE_ID}/params.json | awk '{ print $1 }')

  initialBalance=$(getAddressBalance "$paymentAddr")
  txOut=$((initialBalance - fee))

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$paymentAddr"+"$txOut" \
    --invalid-hereafter 5000000 \
    --fee "$fee" \
    --certificate-file ${SP_NODE_ID}/deleg.cert \
    --out-file ${SP_NODE_ID}/tx.raw

  cardano-cli transaction sign \
    --tx-body-file ${SP_NODE_ID}/tx.raw \
    --signing-key-file "$delegatorPaymentSKey" \
    --signing-key-file "$delegatorStakeSKey" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/tx.signed

  cardano-cli transaction submit \
    --tx-file ${SP_NODE_ID}/tx.signed \
    --testnet-magic 888

  updatedBalance=$(getAddressBalance "$paymentAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]; do
    updatedBalance=$(getAddressBalance "$paymentAddr")
    sleep 1
  done

  # creating certs
  echo "Deregister stake pool ${SP_NODE_ID}..."
  currentBalance=$(getAddressBalance "$genesisAddr")

  cardano-cli stake-pool deregistration-certificate \
    --cold-verification-key-file "$coldVKey" \
    --epoch "$RETIRING_EPOCH" \
    --out-file ${SP_NODE_ID}/pool.dereg

  utxo=$(cardano-cli query utxo --address "$genesisAddr" --testnet-magic 888 | awk 'NR == 3 {printf("%s#%s", $1, $2)}')

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$genesisAddr"+0 \
    --invalid-hereafter 500000 \
    --fee 0 \
    --certificate-file ${SP_NODE_ID}/pool.dereg \
    --out-file ${SP_NODE_ID}/tx.tmp

  fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${SP_NODE_ID}/tx.tmp \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --testnet-magic 888 \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file ${SP_NODE_ID}/params.json | awk '{ print $1 }')

  initialBalance=$(getAddressBalance "$genesisAddr")
  txOut=$((initialBalance - fee))

  cardano-cli transaction build-raw \
    --tx-in "$utxo" \
    --tx-out "$genesisAddr"+"$txOut" \
    --invalid-hereafter 500000 \
    --fee "$fee" \
    --certificate-file ${SP_NODE_ID}/pool.dereg \
    --out-file ${SP_NODE_ID}/tx.raw

  cardano-cli transaction sign \
    --tx-body-file ${SP_NODE_ID}/tx.raw \
    --signing-key-file "$genesisSKey" \
    --signing-key-file "$coldKey" \
    --signing-key-file "$stakeKey" \
    --testnet-magic 888 \
    --out-file ${SP_NODE_ID}/tx.signed

  cardano-cli transaction submit \
    --tx-file ${SP_NODE_ID}/tx.signed \
    --testnet-magic 888

  updatedBalance=$(getAddressBalance "$genesisAddr")

  while [ "$currentBalance" -eq "$updatedBalance" ]; do
    updatedBalance=$(getAddressBalance "$genesisAddr")
    sleep 1
  done

  echo "Done!"
}
