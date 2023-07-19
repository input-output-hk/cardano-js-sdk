#!/bin/bash

# Simple scripts which overrides the original cardano-node-ogmios.sh file from the
# cardano-node-ogmios docker image.

# Used to support the e2e test to check the projector is able to
# connect / reconnect to the ogmios server.

# If the test set the file, wait for its removal before starting the container
while [ -f /sdk-ipc/prevent_ogmios ]; do sleep 10; done

# Start the cardano-node-ogmios as normal
/root/cardano-node-ogmios.sh
