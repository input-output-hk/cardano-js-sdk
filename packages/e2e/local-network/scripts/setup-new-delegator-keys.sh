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

NETWORK_MAGIC=888
UTXO_DIR=network-files/utxo-keys
TRANSACTIONS_DIR=network-files/transactions
DELEGATORS_DIR=network-files/stake-delegator-keys

AMOUNT_PER_DELEGATOR='500000000000' # 500K ADA

mkdir -p "$TRANSACTIONS_DIR"
mkdir -p "$DELEGATORS_DIR"

while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "setup-new-delegator-keys.sh: CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH file doesn't exist, waiting..."
  sleep 2
done

# ----------------------

# GENERATE NEW PAYMENT KEYS

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli conway address key-gen \
    --verification-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.vkey" \
    --signing-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.skey"
done

# GENERATE NEW STAKE

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli conway stake-address key-gen \
    --verification-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.vkey" \
    --signing-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.skey"
done

# BUILD ADDRESSES FOR OUR NEW KEYS

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli conway address build \
    --testnet-magic $NETWORK_MAGIC \
    --payment-verification-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.vkey" \
    --stake-verification-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.vkey" \
    --out-file  "${DELEGATORS_DIR}/payment${NODE_ID}.addr"
done

# BUILD ADDRESSES FOR THE EXISTING KEYS, WE WILL NEED THEM FOR OUR FUTURE TRANSACTIONS

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli conway address build \
    --testnet-magic $NETWORK_MAGIC \
    --payment-verification-key-file "${UTXO_DIR}/utxo${NODE_ID}.vkey" \
    --out-file  "${UTXO_DIR}/utxo${NODE_ID}.addr"
done

# FUND OUR NEWLY CREATED ADDRESSES

stakeAddr="$(cat "${UTXO_DIR}/utxo1.addr")"
currentBalance=$(getAddressBalance "$stakeAddr")
echo "Funding stake addresses with ${AMOUNT_PER_DELEGATOR}"

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli conway transaction build \
    --testnet-magic $NETWORK_MAGIC \
    --tx-in "$(cardano-cli query utxo --address "$(cat "${UTXO_DIR}/utxo${NODE_ID}.addr")" --testnet-magic $NETWORK_MAGIC --out-file /dev/stdout | jq -r 'keys[0]')" \
    --tx-out "$(cat ${DELEGATORS_DIR}/payment${NODE_ID}.addr)+${AMOUNT_PER_DELEGATOR}" \
    --change-address "$(cat ${UTXO_DIR}/utxo${NODE_ID}.addr)" \
    --out-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.raw"

    cardano-cli conway transaction sign --testnet-magic $NETWORK_MAGIC \
      --tx-body-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.raw" \
      --signing-key-file "${UTXO_DIR}/utxo${NODE_ID}.skey" \
      --out-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.signed"

    cardano-cli conway transaction submit \
      --testnet-magic $NETWORK_MAGIC \
      --tx-file "${TRANSACTIONS_DIR}/tx${NODE_ID}.signed"
done

updatedBalance=$(getAddressBalance "$stakeAddr")

while [ "$currentBalance" -eq "$updatedBalance" ]; do
  updatedBalance=$(getAddressBalance "$stakeAddr")
  sleep 1
done

sleep 10

# SHOW THE UTXO DISTRIBUTION

cardano-cli conway query utxo --whole-utxo --testnet-magic $NETWORK_MAGIC

# REGISTER STAKE ADDRESSES

echo "Registering $(cat "${DELEGATORS_DIR}/payment${NODE_ID}.addr")"

keyDeposit=2000000
stakeAddr="$(cat "${DELEGATORS_DIR}/payment1.addr")"
currentBalance=$(getAddressBalance "$stakeAddr")

for NODE_ID in ${SP_NODES_ID}; do
  cardano-cli conway stake-address registration-certificate \
    --stake-verification-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.vkey" \
    --key-reg-deposit-amt ${keyDeposit} \
    --out-file "${TRANSACTIONS_DIR}/staking${NODE_ID}reg.cert"

  cardano-cli conway transaction build \
    --testnet-magic $NETWORK_MAGIC \
    --tx-in "$(cardano-cli query utxo --address "$(cat "${DELEGATORS_DIR}/payment${NODE_ID}.addr")" --testnet-magic $NETWORK_MAGIC --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address "$(cat ${DELEGATORS_DIR}/payment${NODE_ID}.addr)" \
    --certificate-file "${TRANSACTIONS_DIR}/staking${NODE_ID}reg.cert" \
    --witness-override 2 \
    --out-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.raw"

  cardano-cli conway transaction sign --testnet-magic $NETWORK_MAGIC \
    --tx-body-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.raw" \
    --signing-key-file "${DELEGATORS_DIR}/payment${NODE_ID}.skey" \
    --signing-key-file "${DELEGATORS_DIR}/staking${NODE_ID}.skey" \
    --out-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.signed"

  cardano-cli conway transaction submit \
    --testnet-magic $NETWORK_MAGIC \
    --tx-file "${TRANSACTIONS_DIR}/reg-stake-tx${NODE_ID}.signed"
done

updatedBalance=$(getAddressBalance "$stakeAddr")

while [ "$currentBalance" -eq "$updatedBalance" ]; do
  updatedBalance=$(getAddressBalance "$stakeAddr")
  sleep 1
done

sleep 10
