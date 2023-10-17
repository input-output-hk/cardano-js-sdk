#!/usr/bin/env bash

# Determine the platform
PLATFORM=$(uname)

# Set the Docker Compose file based on the platform
if [ "$PLATFORM" == "Darwin" ]; then
  COMPOSE_FILE="docker-compose.mac.yml"
else
  COMPOSE_FILE="docker-compose.yml"
fi

echo $COMPOSE_FILE
echo "FILES HERE" $FILES

docker compose -p local-network-e2e -f "$COMPOSE_FILE" -f ../../compose/common.yml $FILES up