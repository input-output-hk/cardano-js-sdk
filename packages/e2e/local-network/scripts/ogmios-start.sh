#!/bin/bash

# Simple script which overrides will run instead of the `/bin/ogmios` binary in the original
# ogmios docker image. It delays starting ogmios based on a sentinel file.

# Used to support the e2e test to check the projector is able to
# connect / reconnect to the ogmios server.

# If the test set the file, wait for its removal before starting the container
while [ -f /sdk-ipc/prevent_ogmios ]; do sleep 10; done

# Start the ogmios as normal
exec /bin/ogmios "$@"
