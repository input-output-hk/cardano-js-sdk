#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(dirname "$(readlink -fm "$0")")"
PACKAGES_DIR="$(dirname "$(dirname "$(dirname "${SCRIPT_DIR}")")")"
WORKSPACE_ROOT="$(dirname "${PACKAGES_DIR}")"
SECRETS_DIR="$PACKAGES_DIR"/cardano-services/placeholder-secrets

yarn --cwd "$PACKAGES_DIR"/e2e local-network:down
yarn --cwd "$PACKAGES_DIR"/e2e local-network:up -d
yarn --cwd "$WORKSPACE_ROOT" build
yarn --cwd "$PACKAGES_DIR"/e2e test:wallet
echo 'Stop writing data'
docker compose -p local-network-e2e stop cardano-db-sync
echo 'Creating snapshot...'
docker compose -p local-network-e2e exec -it postgres /bin/bash -c "pg_dump --username $(cat "$SECRETS_DIR"/postgres_user) $(cat "$SECRETS_DIR"/postgres_db)" > "$SCRIPT_DIR"/local-network.bak
cd "$SCRIPT_DIR" && tar -cvf local-network-db-snapshot.tar local-network.bak
echo 'Snapshot created.'
yarn --cwd "$PACKAGES_DIR"/e2e local-network:down
