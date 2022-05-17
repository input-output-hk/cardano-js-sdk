#!/usr/bin/env bash

set -euo pipefail

npm publish --cwd ./packages/blockfrost && \
npm publish --cwd ./packages/cardano-services && \
npm publish --cwd ./packages/cardano-services-client && \
npm publish --cwd ./packages/cip2 && \
npm publish --cwd ./packages/cip30 && \
npm publish --cwd ./packages/web-extension && \
npm publish --cwd ./packages/core && \
npm publish --cwd ./packages/golden-test-generator && \
npm publish --cwd ./packages/ogmios && \
npm publish --cwd ./packages/rabbitmq && \
npm publish --cwd ./packages/util-dev && \
npm publish --cwd ./packages/wallet
