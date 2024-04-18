#!/usr/bin/env bash
set -eo pipefail

LOCAL_NETWORK_CONTAINER_NAME="local-network-e2e-local-testnet-1"

# Add here the volumes you want to snapshot
VOLUMES="local-network-e2e_db-sync-data local-network-e2e_node-db local-network-e2e_node-ipc local-network-e2e_local-network-files local-network-e2e_postgres_data"

SCRIPT_DIR=$(dirname $(readlink -fm $0))
PACKAGES_DIR=$(dirname $(dirname $(dirname $SCRIPT_DIR)))
WORKSPACE_ROOT=$(dirname $PACKAGES_DIR)
SNAPSHOTS_DIR=$WORKSPACE_ROOT/packages/e2e/local-network/snapshots
SDK_IPC_DIR=$WORKSPACE_ROOT/packages/e2e/local-network/sdk-ipc
SECRETS_DIR=$WORKSPACE_ROOT/compose/placeholder-secrets
CONFIG_DIR=$SNAPSHOTS_DIR/config.tar.gz
SNAPSHOT_HASH_FILE=$SNAPSHOTS_DIR/hash
SNAPSHOT_DATE_FILE="$SNAPSHOTS_DIR"/datetime

DB_DB_SYNC=$(cat $SECRETS_DIR/postgres_db_db_sync)
USER=$(cat $SECRETS_DIR/postgres_user)
PASSWORD=$(cat $SECRETS_DIR/postgres_password)

export DB_SYNC_CONNECTION_STRING="postgresql://${USER}:${PASSWORD}@localhost:5432/${DB_DB_SYNC}"

yarn cleanup
yarn
yarn build

yarn workspace @cardano-sdk/e2e local-network:down
yarn workspace @cardano-sdk/e2e local-network:up -d --build

echo 'Snapshots network configuration...'

docker exec $LOCAL_NETWORK_CONTAINER_NAME tar -czf /root/config.tar.gz -C /root/config .
docker cp $LOCAL_NETWORK_CONTAINER_NAME:/root/config.tar.gz "$SNAPSHOTS_DIR"
echo "Backup completed successfully and stored at $CONFIG_DIR"

tar -czf "$SNAPSHOTS_DIR"/sdk-ipc.tar.gz -C "$SDK_IPC_DIR" .
echo "Backup completed successfully and stored at $SDK_IPC_DIR"

yarn workspace @cardano-sdk/e2e wait-for-network

echo 'Stop network services...'
# Stop network services but doesnt delete the volumes
yarn workspace @cardano-sdk/e2e local-network:persistent:down

SNAPSHOT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Snapshot date: $SNAPSHOT_DATE"
echo "$SNAPSHOT_DATE" > "$SNAPSHOT_DATE_FILE"

echo 'Creating snapshots...'

for VOLUME in $VOLUMES; do
  docker run --rm -v $VOLUME:/data -v $SNAPSHOTS_DIR:/backup ubuntu tar czvf /backup/$VOLUME.tar.gz -C /data .
  echo "Snapshot $VOLUME created."
done

echo 'Snapshots created.'
"$SCRIPT_DIR"/generate-hash.sh > "$SNAPSHOT_HASH_FILE"

# This step will delete the volumes
yarn workspace @cardano-sdk/e2e local-network:down
