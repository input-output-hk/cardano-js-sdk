#!/usr/bin/env bash

set -euo pipefail

npm publish --cwd ./packages/core && \
npm publish --cwd ./packages/golden-test-generator
