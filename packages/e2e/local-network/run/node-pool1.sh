#!/usr/bin/env bash

cardano-node run \
  --config config.json \
  --topology node-pool1/topology.json \
  --database-path node-pool1/db \
  --socket-path sockets/node-pool1.sock \
  --shelley-kes-key node-pool1/shelley/kes.skey \
  --shelley-vrf-key node-pool1/shelley/vrf.skey \
  --shelley-operational-certificate node-pool1/shelley/node.cert \
  --host-addr 0.0.0.0 \
  --port 3003 |
  tee -a node-pool1/node.log
