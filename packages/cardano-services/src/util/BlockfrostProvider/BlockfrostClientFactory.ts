import { AvailableNetworks } from '../../Program';
import { BlockFrostAPI } from '@blockfrost/blockfrost-js';

let blockfrostApi: BlockFrostAPI | undefined;

/**
 * Gets the singleton blockfrost API instance.
 *
 * @returns The blockfrost API instance, this function always returns the same instance.
 */
export const getBlockfrostApi = () => {
  if (blockfrostApi !== undefined) return blockfrostApi;

  if (process.env.BLOCKFROST_API_KEY === undefined || process.env.BLOCKFROST_API_KEY === '')
    throw new Error('BLOCKFROST_API_KEY environment variable is required');

  if (process.env.NETWORK === undefined) throw new Error('NETWORK environment variable is required');

  // network is not mandatory, we keep it for safety.
  blockfrostApi = new BlockFrostAPI({
    network: process.env.NETWORK as AvailableNetworks,
    projectId: process.env.BLOCKFROST_API_KEY
  });

  return blockfrostApi;
};

// for testing purpose
export const clearBlockfrostApi = () => {
  if (blockfrostApi !== undefined) blockfrostApi = undefined;
};
