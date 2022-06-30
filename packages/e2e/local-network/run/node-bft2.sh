#!/usr/bin/env bash

cardano-node run \
  --config config.json \
  --topology node-bft2/topology.json \
  --database-path node-bft2/db \
  --socket-path sockets/node-bft2.sock \
  --shelley-kes-key node-bft2/shelley/kes.skey \
  --shelley-vrf-key node-bft2/shelley/vrf.skey \
  --shelley-operational-certificate node-bft2/shelley/node.cert \
  --host-addr 0.0.0.0 \
  --port 3002 \
  --delegation-certificate node-bft2/byron/delegate.cert \
  --signing-key node-bft2/byron/delegate.key |
  tee -a node-bft2/node.log
