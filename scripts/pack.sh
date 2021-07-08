#!/usr/bin/env bash

set -euo pipefail

npm pack --cwd ./packages/core && \
npm pack --cwd ./packages/golden-test-generator
