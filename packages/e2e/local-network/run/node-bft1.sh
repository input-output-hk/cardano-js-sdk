#!/usr/bin/env bash

cardano-node run \
  --config config.json \
  --topology node-bft1/topology.json \
  --database-path node-bft1/db \
  --socket-path sockets/node-bft1.sock \
  --shelley-kes-key node-bft1/shelley/kes.skey \
  --shelley-vrf-key node-bft1/shelley/vrf.skey \
  --shelley-operational-certificate node-bft1/shelley/node.cert \
  --host-addr 0.0.0.0 \
  --port 3001 \
  --delegation-certificate node-bft1/byron/delegate.cert \
  --signing-key node-bft1/byron/delegate.key |
  tee -a node-bft1/node.log
