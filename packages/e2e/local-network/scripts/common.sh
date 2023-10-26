#!/bin/bash

wait_tx_complete() {
  utxo_to_check="$1"
  timeout=0
  max_timeout=30
  while [ $timeout -lt $max_timeout ]; do
    output=$(cardano-cli query utxo --tx-in "${utxo_to_check}" --testnet-magic 888)
    line_count=$(echo "$output" | awk 'END {print NR}')
    if [ $line_count -eq 2 ]; then
      echo "Transaction completed"
      return 0
    fi
    timeout=$((timeout + 1))
    sleep 1
  done
  echo "Timeout: Transaction not completed in $max_timeout sec."
  return 1
}
