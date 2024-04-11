#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -fm "$0")")
PACKAGES_DIR=$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")
WORKSPACE_ROOT=$(dirname "$PACKAGES_DIR")

# Define an array of directories to hash
DIRECTORIES=(
    "$WORKSPACE_ROOT/packages/e2e/local-network/scripts"
    "$WORKSPACE_ROOT/packages/e2e/local-network/templates"
)

# Function to calculate a combined hash of all files in a directory recursively
calculate_hash() {
    find "$1" -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -d" " -f1
}

# Initialize an empty string to accumulate combined hashes
all_hashes=""

# Iterate over each directory and calculate its hash
for dir in "${DIRECTORIES[@]}"; do
    dir_hash=$(calculate_hash "$dir")
    all_hashes+="$dir_hash"
done

# Final combined hash of all directory hashes
combined_hash=$(echo "$all_hashes" | sha256sum | cut -d" " -f1)

echo "$combined_hash"
