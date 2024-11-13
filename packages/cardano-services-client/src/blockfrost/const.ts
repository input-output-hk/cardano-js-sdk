import { Milliseconds } from '@cardano-sdk/core';

export const DEFAULT_BLOCKFROST_API_VERSION = 'v0';

export const DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG = {
  increaseAmount: 10,
  increaseInterval: Milliseconds(1000),
  size: 500
};

export const DEFAULT_BLOCKFROST_URLS = {
  mainnet: 'https://cardano-mainnet.blockfrost.io',
  preprod: 'https://cardano-preprod.blockfrost.io',
  preview: 'https://cardano-preview.blockfrost.io',
  sanchonet: 'https://cardano-sanchonet.blockfrost.io'
};
