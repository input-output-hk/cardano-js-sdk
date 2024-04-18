#!/bin/bash

export PATH=$PWD/bin:$PATH

# Define the base directory containing the node-spX folders
BASE_DIR=/home/angel/Sources/iog/ts/cardano-js-sdk/packages/e2e/local-network/snapshots/local-network-e2e_local-network-files/

# Initialize an empty array to hold all the data
all_data=()

# Loop through directories in $BASE_DIR
for dir in $BASE_DIR/node-sp*; do
    if [ -d "$dir" ]; then
        echo "Processing $dir..."

        # Initialize an array for this node's credentials
        node_creds=()

        # Read each file and construct a JSON object for it
        for file in "opcert.cert" "vrf.skey" "kes.skey"; do
            if [ -f "$dir/$file" ]; then
                content=$(cat "$dir/$file")
                node_creds+=("$content")
            else
                echo "Warning: File $dir/$file not found, skipping..."
            fi
        done

        # Combine the credentials into a sub-array for the current node
        all_data+=("$(jq -n --argjson data "$(printf '%s\n' "${node_creds[@]}" | jq -s '.')" '$data')")
    fi
done

# Combine all nodes' data into the top-level JSON array
final_json=$(jq -n --argjson data "$(printf '%s\n' "${all_data[@]}" | jq -s '.')" '$data')

echo "$final_json" | jq . > bulk-creds.json
echo "Generated bulk-creds.json with all node credentials."

