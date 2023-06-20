#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(dirname "$(readlink -fm "$0")")"
PACKAGES_DIR="$(dirname "$(dirname "$(dirname "${SCRIPT_DIR}")")")"
WORKSPACE_ROOT="$(dirname "${PACKAGES_DIR}")"
SECRETS_DIR="$WORKSPACE_ROOT"/compose/placeholder-secrets

export DB_SYNC_CONNECTION_STRING="postgresql://$(cat "$SECRETS_DIR"/postgres_user):$(cat "$SECRETS_DIR"/postgres_password)@localhost:5435/$(cat "$SECRETS_DIR"/postgres_db_db_sync)"

yarn --cwd "$PACKAGES_DIR"/e2e local-network:down
yarn --cwd "$PACKAGES_DIR"/e2e local-network:up -d --build
yarn --cwd "$WORKSPACE_ROOT" build
yarn --cwd "$PACKAGES_DIR"/e2e wait-for-network
yarn --cwd "$PACKAGES_DIR"/e2e test:wallet
yarn --cwd "$PACKAGES_DIR"/e2e test:long-running
yarn --cwd "$PACKAGES_DIR"/e2e test:local-network register-pool.test.ts
echo 'Stop writing data'
docker compose -p local-network-e2e stop cardano-db-sync
docker compose -p local-network-e2e stop handle-projector
docker compose -p local-network-e2e stop stake-pool-projector
echo 'Creating snapshot...'
docker compose -p local-network-e2e exec -it postgres /bin/bash -c "pg_dump --username $(cat "$SECRETS_DIR"/postgres_user) $(cat "$SECRETS_DIR"/postgres_db_db_sync)" > "$SCRIPT_DIR"/localnetwork.bak
docker compose -p local-network-e2e exec -it postgres /bin/bash -c "pg_dump --username $(cat "$SECRETS_DIR"/postgres_user) $(cat "$SECRETS_DIR"/postgres_db_handle)" > "$SCRIPT_DIR"/localnetwork-handle.bak
docker compose -p local-network-e2e exec -it postgres /bin/bash -c "pg_dump --username $(cat "$SECRETS_DIR"/postgres_user) $(cat "$SECRETS_DIR"/postgres_db_stake_pool)" > "$SCRIPT_DIR"/localnetwork-stake-pool.bak
cd "$SCRIPT_DIR"
tar -cvf localnetwork-db-snapshot.tar localnetwork.bak
tar -cvf localnetwork-handle-db-snapshot.tar localnetwork-handle.bak
tar -cvf localnetwork-stake-pool-db-snapshot.tar localnetwork-stake-pool.bak
rm localnetwork.bak
#rm localnetwork-handle.bak
rm localnetwork-stake-pool.bak
echo 'Snapshot created.'
yarn --cwd "$PACKAGES_DIR"/e2e local-network:down
