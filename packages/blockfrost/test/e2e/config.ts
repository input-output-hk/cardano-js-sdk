import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { blockfrostAssetProvider, blockfrostChainHistoryProvider } from '../../src';

const testnetprojectId = process.env.BLOCKFROST_API_KEY;
if (!testnetprojectId) throw new Error('BLOCKFROST_API_KEY not set');

const blockfrostApi = new BlockFrostAPI({ isTestnet: true, projectId: testnetprojectId });
export const assetProvider = blockfrostAssetProvider(blockfrostApi);
export const chainHistoryProvider = blockfrostChainHistoryProvider(blockfrostApi);
