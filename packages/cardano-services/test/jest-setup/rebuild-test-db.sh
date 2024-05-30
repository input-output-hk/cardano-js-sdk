#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR=$(dirname $(readlink -fm $0))
PACKAGES_DIR=$(dirname $(dirname $(dirname $SCRIPT_DIR)))
WORKSPACE_ROOT=$(dirname $PACKAGES_DIR)
SECRETS_DIR=$WORKSPACE_ROOT/compose/placeholder-secrets

DB_DB_SYNC=$(cat $SECRETS_DIR/postgres_db_db_sync)
USER=$(cat $SECRETS_DIR/postgres_user)
PASSWORD=$(cat $SECRETS_DIR/postgres_password)

export DB_SYNC_CONNECTION_STRING="postgresql://${USER}:${PASSWORD}@localhost:5435/${DB_DB_SYNC}"

yarn cleanup
yarn
yarn build
yarn test:build:verify

yarn workspace @cardano-sdk/e2e local-network:down
yarn workspace @cardano-sdk/e2e local-network:up -d --build

yarn workspace @cardano-sdk/e2e test:wallet
yarn workspace @cardano-sdk/e2e test:long-running simple-delegation-rewards.test.ts
yarn workspace @cardano-sdk/e2e test:local-network register-pool.test.ts

TL_LEVEL="${TL_LEVEL:=info}" node "$SCRIPT_DIR/mint-handles.js"

echo 'Stop providing data to projectors'
docker compose -p local-network-e2e stop cardano-node ogmios
sleep 2

echo 'Creating snapshots...'
for DB_FILE in $(
  cd $SECRETS_DIR
  ls postgres_db_*
); do
  docker compose -p local-network-e2e exec -it postgres /bin/bash -c "pg_dump --create --username $USER $(cat $SECRETS_DIR/$DB_FILE)" >$SCRIPT_DIR/snapshots/$(echo $DB_FILE | sed -e s/postgres_db_//).sql
done
echo 'Snapshots created.'

yarn workspace @cardano-sdk/e2e local-network:down
