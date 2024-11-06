#!/usr/bin/env bash

# Unofficial bash strict mode.
# See: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root_path="$(cd "$here/.." && pwd)"
cd "$root_path"

rm -rf ./network-files/node-sp*/*
rm -rf ./sockets/*
rm -rf ./config/*
rm -rf ./logs/*
rm -rf /sdk-ipc/config
rm -rf /sdk-ipc/handle_policy_ids
