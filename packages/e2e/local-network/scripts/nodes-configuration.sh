#!/usr/bin/env bash

AMOUNT_PER_NODE='10000000000000'
NUM_SPO_NODES=11
SPO_NODES_ID=$(seq 1 ${NUM_SPO_NODES})
SPO_NODES=$(for i in ${SPO_NODES_ID} ; do echo "node-spo${i}" ; done)
