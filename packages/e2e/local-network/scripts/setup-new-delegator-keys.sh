#!/usr/bin/env bash

# mkfiles.sh
# This scripts uses set -x to show in terminal the commands executed by the script. Remove or comment set -x to disable this behavior
# The "exec 2>" below this comment helps the user to differenciate between the commands and its outputs by changing the color
# of the set -x output (the commands).

exec 2> >(while IFS= read -r line; do echo -e "\e[34m${line}\e[0m" >&2; done)

# Unofficial bash strict mode.
# See: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -x
set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

source ./scripts/nodes-configuration.sh

UNAME=$(uname -s) SED=
case $UNAME in
  Darwin )      SED="gsed";;
  Linux )       SED="sed";;
esac

sprocket() {
  if [ "$UNAME" == "Windows_NT" ]; then
    # Named pipes names on Windows must have the structure: "\\.\pipe\PipeName"
    # See https://docs.microsoft.com/en-us/windows/win32/ipc/pipe-names
    echo -n '\\.\pipe\'
    echo "$1" | sed 's|/|\\|g'
  else
    echo "$1"
  fi
}

getAddressBalance() {
  cardano-cli query utxo \
    --address "$1" \
    --testnet-magic 888 >fullUtxo.out

  tail -n +3 fullUtxo.out | sort -k3 -nr >balance.out

  total_balance=0
  while read -r utxo; do
    utxo_balance=$(awk '{ print $3 }' <<<"${utxo}")
    total_balance=$(("$total_balance" + "$utxo_balance"))
  done <balance.out

  echo ${total_balance}
}

getBlockHeight() {
  cardano-cli query tip --testnet-magic $NETWORK_MAGIC | jq -r '.block'
}

submitTransactionWithRetry() {
  local txFile=$1
  local retryCount=${2:-0}
  local numberOfConfirmations=5

  if [ "$retryCount" -ge 5 ]; then
    echo "Transaction failed after $retryCount retries"
    return 1
  fi

  cardano-cli latest transaction submit --testnet-magic $NETWORK_MAGIC --tx-file "$txFile"

  local txId=$(cardano-cli latest transaction txid --tx-file "$txFile")

  local mempoolTx="true"
  while [ "$mempoolTx" == "true" ]; do
    echo "Transaction is still in the mempool, waiting ${txId}"
    sleep 1
    mempoolTx=$(cardano-cli latest query tx-mempool --testnet-magic $NETWORK_MAGIC tx-exists ${txId} --out-file /dev/stdout | jq -r '.exists')
  done

  local initialTip=$(getBlockHeight)
  local currentTip=$initialTip
  local utxo="null"
  while [ $(($currentTip - $initialTip)) -lt $numberOfConfirmations ]; do
    sleep 1
    utxo=$(cardano-cli query utxo --tx-in "${txId}#0" --testnet-magic $NETWORK_MAGIC --out-file /dev/stdout | jq -r 'keys[0]')
    if [ "$utxo" == "null" ]; then
      # Transaction was rolled back
      break;
    fi
    currentTip=$(getBlockHeight)
  done

  if [ "$utxo" == "null" ]; then
    echo "Transaction rolled back, retrying ${retryCount} ..."
    submitTransactionWithRetry "$txFile" $((retryCount + 1))
    return $?
  fi

  echo "Transaction successful ${txId}"
}

NETWORK_MAGIC=888
UTXO_DIR=network-files/utxo-keys
TRANSACTIONS_DIR=network-files/transactions
DELEGATORS_DIR=network-files/stake-delegator-keys

AMOUNT_PER_DELEGATOR='500000000000' # 500K ADA

mkdir -p "$TRANSACTIONS_DIR"
mkdir -p "$DELEGATORS_DIR"

# ----------------------

# GENERATE NEW PAYMENT KEYS

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli latest address key-gen \
    --verification-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.vkey" \
    --signing-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.skey"
done

# GENERATE NEW STAKE

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli latest stake-address key-gen \
    --verification-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.vkey" \
    --signing-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.skey"
done

# BUILD ADDRESSES FOR OUR NEW KEYS

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli latest address build \
    --testnet-magic $NETWORK_MAGIC \
    --payment-verification-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.vkey" \
    --stake-verification-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.vkey" \
    --out-file  "${DELEGATORS_DIR}/payment${NODE_ID}.addr"
done

# BUILD ADDRESSES FOR THE EXISTING KEYS, WE WILL NEED THEM FOR OUR FUTURE TRANSACTIONS

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli latest address build \
    --testnet-magic $NETWORK_MAGIC \
    --payment-verification-key-file "${UTXO_DIR}/utxo${NODE_ID}.vkey" \
    --out-file  "${UTXO_DIR}/utxo${NODE_ID}.addr"
done

# FUND OUR NEWLY CREATED ADDRESSES

for NODE_ID in ${SP_NODES_ID}; do
  sourceAddr="$(cat "${UTXO_DIR}/utxo${NODE_ID}.addr")"
  destAddr="$(cat ${DELEGATORS_DIR}/payment${NODE_ID}.addr)"
  echo "Funding ${destAddr} with ${AMOUNT_PER_DELEGATOR}"

  cardano-cli latest transaction build \
    --testnet-magic $NETWORK_MAGIC \
    --tx-in "$(cardano-cli query utxo --address "$sourceAddr" --testnet-magic $NETWORK_MAGIC --out-file /dev/stdout | jq -r 'keys[0]')" \
    --tx-out "${destAddr}+${AMOUNT_PER_DELEGATOR}" \
    --change-address "$sourceAddr" \
    --out-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.raw"

  cardano-cli latest transaction sign --testnet-magic $NETWORK_MAGIC \
    --tx-body-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.raw" \
    --signing-key-file "${UTXO_DIR}/utxo${NODE_ID}.skey" \
    --out-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.signed"

  if [ "$NODE_ID" -eq 1 ]; then
    # This is the first transaction after startin the network.
    # It usually takes a long time to be included in a block and often rolled back, so use submit with retry.
    # Do not use submit with retry for regular transactions because it waits for 5 block confirmations before it returns
    submitTransactionWithRetry "${TRANSACTIONS_DIR}/tx${NODE_ID}.signed"
  else
    cardano-cli latest transaction submit --testnet-magic $NETWORK_MAGIC --tx-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.signed"
  fi
done

# Wait for funds to reach destAddr
for NODE_ID in ${SP_NODES_ID}; do
  destAddr="$(cat ${DELEGATORS_DIR}/payment${NODE_ID}.addr)"

  currentBalance=$(getAddressBalance "$destAddr")
  while [ "$currentBalance" -lt "$AMOUNT_PER_DELEGATOR" ]; do
    echo "Waiting for funds to reach ${destAddr} ${currentBalance} < ${AMOUNT_PER_DELEGATOR}"
    currentBalance=$(getAddressBalance "$destAddr")
    sleep 1
  done
done

sleep 10

# SHOW THE UTXO DISTRIBUTION

cardano-cli query utxo --whole-utxo --testnet-magic $NETWORK_MAGIC

# REGISTER STAKE ADDRESSES

keyDeposit=2000000
stakeAddr="$(cat "${DELEGATORS_DIR}/payment1.addr")"
currentBalance=$(getAddressBalance "$stakeAddr")

for NODE_ID in ${SP_NODES_ID}; do
  stakeAddr=$(cat "${DELEGATORS_DIR}/payment${NODE_ID}.addr")
  echo "Registering $stakeAddr"

  cardano-cli latest stake-address registration-certificate \
    --stake-verification-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.vkey" \
    --key-reg-deposit-amt ${keyDeposit} \
    --out-file "${TRANSACTIONS_DIR}/staking${NODE_ID}reg.cert"

  # Wait for utxo to become available
  txIn="null";
  while [ "$txIn" == "null" ]; do
    echo "Waiting for ${stakeAddr} UTxO..."
    txInJson="$(cardano-cli latest query utxo --address "$stakeAddr" --testnet-magic $NETWORK_MAGIC --out-file /dev/stdout)";
    txIn=$(jq -r 'keys[0]' <<< "$txInJson");
    sleep 0.1
  done

  cardano-cli latest transaction build \
    --testnet-magic $NETWORK_MAGIC \
    --tx-in "$txIn" \
    --change-address "$(cat ${DELEGATORS_DIR}/payment${NODE_ID}.addr)" \
    --certificate-file "${TRANSACTIONS_DIR}/staking${NODE_ID}reg.cert" \
    --witness-override 2 \
    --out-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.raw"

  cardano-cli latest transaction sign --testnet-magic $NETWORK_MAGIC \
    --tx-body-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.raw" \
    --signing-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.skey" \
    --signing-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.skey" \
    --out-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.signed"

  cardano-cli latest transaction submit --testnet-magic $NETWORK_MAGIC --tx-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.signed"
done

updatedBalance=$(getAddressBalance "$stakeAddr")

while [ "$currentBalance" -eq "$updatedBalance" ]; do
  updatedBalance=$(getAddressBalance "$stakeAddr")
  sleep 1
done

sleep 10
