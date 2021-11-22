import { blockfrostWalletProvider } from '../../src';

const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');
const isTestnet = networkId === 0;

export const walletProvider = (() => {
  const walletProviderName = process.env.WALLET_PROVIDER;
  if (walletProviderName === 'blockfrost') {
    const projectId = process.env.BLOCKFROST_API_KEY;
    if (!projectId) throw new Error('BLOCKFROST_API_KEY not set');
    return blockfrostWalletProvider({ isTestnet, projectId });
  }
  throw new Error(`WALLET_PROVIDER unsupported: ${walletProviderName}`);
})();
