import { blockfrostAssetProvider, blockfrostWalletProvider } from '../../src';

const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');
const isTestnet = networkId === 0;

const projectId = process.env.BLOCKFROST_API_KEY;
if (!projectId) throw new Error('BLOCKFROST_API_KEY not set');

export const walletProvider = blockfrostWalletProvider({ isTestnet, projectId });
export const assetProvider = blockfrostAssetProvider({ isTestnet, projectId });
