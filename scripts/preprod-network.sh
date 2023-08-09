#!/bin/bash

# Please refer to the 'GETTING_STARTED.md' guide for more details.

set -e
echo "
    ###########################################################
    #                   !!! WARNING !!!                       #
    # Do not use this script for production deployments.      #
    # This script provides a quick way to start the services  #
    # needed for learning and exploring the Cardano SDK.      #
    # It does not implement any security policies, UAC or     #
    # other topics related to production deployments.         #
    ###########################################################
"

export NETWORK="preprod"
# Init only the minimum services needed for getting started
SERVICES="postgres cardano-node-ogmios cardano-db-sync provider-server"

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [up|down|dump]"
  exit 1
fi

# Check if the argument is 'up' or 'down'
if [[ $1 != "up" && $1 != "down" && $1 != "dump" ]]; then
  echo "Error: Argument must be either 'up', 'down' or 'dump'"
  echo "dump: will display the render compose file in canonical format"
  exit 1
fi

if [ "$1" == "dump" ]; then
  ACTION="config"
  MSG="Dumping rendered compose file"
elif [ "$1" == "down" ]; then
  ACTION=$1
  # docker compose down does not take services arg
  unset SERVICES
  MSG="Stopping the services on ${NETWORK} network"
else
  ACTION="up -d"
  MSG="Starting the services on ${NETWORK} network"
fi

# Check Docker version supports docker compose V2
COMPOSE_VERSION=$(docker compose version --short) || {
  echo "Error: docker not found. 'docker compose' failed with $?"
  exit 1
}
COMPOSE_MIN_VERSION="2.0"

if [ "$(printf '%s\n' "$COMPOSE_MIN_VERSION" "$COMPOSE_VERSION" | sort -V | head -n1)" != "$COMPOSE_MIN_VERSION" ]; then
  echo "Error: Docker version must be at least ${COMPOSE_MIN_VERSION} to support compose V2"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Execute everything from the project root
cd ${SCRIPT_DIR}/..

CARDANO_SERVICES_DIR="packages/cardano-services"

# Start/Stop the network
echo $MSG
docker compose -p cardano-services-$NETWORK -f ${CARDANO_SERVICES_DIR}/docker-compose.yml -f compose/common.yml $ACTION $SERVICES

cd - >/dev/null
