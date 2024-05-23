#!/usr/bin/env bash

set -euo pipefail

while ! docker exec -i local-network-e2e-local-testnet-1 test -e /root/network-files/run/done 2> /dev/null ; do
  echo Waiting...
  sleep 10
done

echo Local network init completed
sleep 10
