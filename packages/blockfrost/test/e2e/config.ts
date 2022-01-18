import { blockfrostAssetProvider, blockfrostWalletProvider } from '../../src';

const testnetprojectId = process.env.BLOCKFROST_API_KEY;
if (!testnetprojectId) throw new Error('BLOCKFROST_API_KEY not set');

export const walletProvider = blockfrostWalletProvider({ isTestnet: true, projectId: testnetprojectId });
export const assetProvider = blockfrostAssetProvider({ isTestnet: true, projectId: testnetprojectId });
