#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname $(readlink -fm $0))
PACKAGES_DIR=$(dirname $(dirname $(dirname $SCRIPT_DIR)))
WORKSPACE_ROOT=$(dirname $PACKAGES_DIR)
SNAPSHOTS_DIR=$WORKSPACE_ROOT/packages/e2e/local-network/snapshots
SNAPSHOT_HASH_FILE=$SNAPSHOTS_DIR/hash
SNAPSHOT_SDK_IPC_DIR=$SNAPSHOTS_DIR/sdk-ipc.tar.gz
SNAPSHOT_CONFIG_DIR=$SNAPSHOTS_DIR/config.tar.gz
TARGET_CONFIG_DIR=$WORKSPACE_ROOT/packages/e2e/local-network/config
TARGET_SDK_IPC_DIR=$WORKSPACE_ROOT/packages/e2e/local-network/sdk-ipc
SNAPSHOT_DATE_FILE="$SNAPSHOTS_DIR"/datetime

# Define where Docker volumes should be restored. This must be the same name as when backed up.
VOLUMES="local-network-e2e_node-db local-network-e2e_local-network-files"

# Ensure Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker does not seem to be running, start it first and retry"
    exit 1
fi

# Check the hash
current_hash=$("$SCRIPT_DIR"/generate-hash.sh | tr -d '[:space:]')
stored_hash=$(cat "$SNAPSHOT_HASH_FILE" | tr -d '[:space:]')

echo "Current hash: $current_hash"
echo "Stored hash: $stored_hash"

if [[ "$current_hash" != "$stored_hash" ]]; then
    echo "Error: Hash mismatch. Cannot restore snapshot."
    exit 1
fi

echo "Hashes match. Proceeding with snapshot restoration..."

echo "Restoring configuration"
rm -rf "$TARGET_CONFIG_DIR"
mkdir -p "$TARGET_CONFIG_DIR"
tar -xzf "$SNAPSHOT_CONFIG_DIR" -C "$TARGET_CONFIG_DIR"

echo "Restoring SDK IPC"
rm -rf "$TARGET_SDK_IPC_DIR"
mkdir -p "$TARGET_SDK_IPC_DIR"
tar -xzf "$SNAPSHOT_SDK_IPC_DIR" -C "$TARGET_SDK_IPC_DIR"

for VOLUME in $VOLUMES; do
    SNAPSHOT_FILE="$SNAPSHOTS_DIR/$VOLUME.tar.gz"

    # Check if the snapshot file exists
    if [ -f "$SNAPSHOT_FILE" ]; then
        # Remove existing volume (if necessary)
        if docker volume ls | grep -qw "$VOLUME"; then
            echo "Removing existing volume $VOLUME..."
            docker volume rm "$VOLUME"
        fi

        # Create a new volume
        echo "Creating new volume $VOLUME..."
        docker volume create "$VOLUME"

        # Restore the volume from the snapshot
        echo "Restoring $VOLUME from snapshot..."
        docker run --rm -v $VOLUME:/data -v $SNAPSHOTS_DIR:/backup ubuntu tar xzvf /backup/$VOLUME.tar.gz -C /data
        echo "Snapshot for $VOLUME restored."
    else
        echo "No snapshot file found for $VOLUME, skipping..."
    fi
done

echo "All snapshots restored."

#systemctl stop systemd-timesyncd
#timedatectl set-time "$(cat "$SNAPSHOT_DATE_FILE")"
