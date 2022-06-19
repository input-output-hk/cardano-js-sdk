#!/usr/bin/env bash

set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

export PATH=$PWD/bin:$PATH

docker rm private-testnet-e2e_cardano-db-sync-extended_1 private-testnet-e2e_postgres_1 private-testnet-e2e_cardano-node-ogmios_1 private-testnet-e2e_private-testnet_1
docker volume rm private-testnet-e2e_db-sync-data private-testnet-e2e_node-db private-testnet-e2e_node-ipc private-testnet-e2e_postgres-data
docker rmi private-testnet-e2e_private-testnet
wait
