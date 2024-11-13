import { AvailableNetworks } from '../../Program';
import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import {
  BlockfrostClient,
  DEFAULT_BLOCKFROST_API_VERSION,
  DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG,
  DEFAULT_BLOCKFROST_URLS
} from '@cardano-sdk/cardano-services-client';
import Bottleneck from 'bottleneck';

let blockfrostApi: BlockFrostAPI | undefined;
let blockfrostClient: BlockfrostClient | undefined;

/**
 * Gets the singleton blockfrost API instance.
 *
 * @returns The blockfrost API instance, this function always returns the same instance.
 */
export const getBlockfrostApi = () => {
  if (blockfrostApi !== undefined) return blockfrostApi;

  // custom hosted instance
  if (process.env.BLOCKFROST_CUSTOM_BACKEND_URL && process.env.BLOCKFROST_CUSTOM_BACKEND_URL !== '') {
    blockfrostApi = new BlockFrostAPI({
      customBackend: process.env.BLOCKFROST_CUSTOM_BACKEND_URL,
      rateLimiter: false
    });

    return blockfrostApi;
  }

  // instance hosted by Blockfrost
  if (process.env.BLOCKFROST_API_KEY === undefined || process.env.BLOCKFROST_API_KEY === '')
    throw new Error('BLOCKFROST_API_KEY or BLOCKFROST_CUSTOM_BACKEND_URL environment variable is required');

  if (process.env.NETWORK === undefined) throw new Error('NETWORK environment variable is required');

  // network is not mandatory, we keep it for safety.
  blockfrostApi = new BlockFrostAPI({
    network: process.env.NETWORK as AvailableNetworks,
    projectId: process.env.BLOCKFROST_API_KEY,
    rateLimiter: false
  });

  return blockfrostApi;
};

/**
 * Gets the singleton blockfrost API instance.
 *
 * @returns The blockfrost API instance, this function always returns the same instance.
 */
export const getBlockfrostClient = (): BlockfrostClient => {
  if (blockfrostClient !== undefined) return blockfrostClient;

  // custom hosted instance
  if (process.env.BLOCKFROST_CUSTOM_BACKEND_URL) {
    blockfrostClient = new BlockfrostClient(
      { apiVersion: DEFAULT_BLOCKFROST_API_VERSION, baseUrl: process.env.BLOCKFROST_CUSTOM_BACKEND_URL },
      { rateLimiter: { schedule: (task) => task() } }
    );

    return blockfrostClient;
  }

  // instance hosted by Blockfrost
  if (!process.env.BLOCKFROST_API_KEY)
    throw new Error('BLOCKFROST_API_KEY or BLOCKFROST_CUSTOM_BACKEND_URL environment variable is required');

  if (!process.env.NETWORK) throw new Error('NETWORK environment variable is required');
  const baseUrl = DEFAULT_BLOCKFROST_URLS[process.env.NETWORK as keyof typeof DEFAULT_BLOCKFROST_URLS];
  if (!baseUrl) throw new Error(`Unsupported NETWORK for blockfrost: ${process.env.NETWORK}`);

  // network is not mandatory, we keep it for safety.
  blockfrostClient = new BlockfrostClient(
    { apiVersion: DEFAULT_BLOCKFROST_API_VERSION, baseUrl, projectId: process.env.BLOCKFROST_API_KEY },
    {
      rateLimiter: new Bottleneck({
        reservoir: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.size,
        reservoirIncreaseAmount: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.increaseAmount,
        reservoirIncreaseInterval: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.increaseInterval,
        reservoirIncreaseMaximum: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.size
      })
    }
  );

  return blockfrostClient;
};

// for testing purpose
export const clearBlockfrostApi = () => {
  if (blockfrostApi !== undefined) blockfrostApi = undefined;
};
