import { blockfrostProvider } from '@cardano-sdk/blockfrost';
import { createInMemoryKeyManager } from '../../src/KeyManagement';
import { createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';

const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');

export const walletProvider = (() => {
  const walletProviderName = process.env.WALLET_PROVIDER;
  if (walletProviderName === 'blockfrost') {
    const projectId = process.env.BLOCKFROST_API_KEY;
    if (!projectId) throw new Error('BLOCKFROST_API_KEY not set');
    return blockfrostProvider({ isTestnet: networkId === 0, projectId });
  }
  throw new Error(`WALLET_PROVIDER unsupported: ${walletProviderName}`);
})();

export const keyManager = (() => {
  const mnemonicWords = (process.env.MNEMONIC_WORDS || '').split(' ');
  if (mnemonicWords.length === 0) throw new Error('MNEMONIC_WORDS not set');
  const password = process.env.WALLET_PASSWORD;
  if (!password) throw new Error('WALLET_PASSWORD not set');
  return createInMemoryKeyManager({ mnemonicWords, networkId, password });
})();

export const stakePoolSearchProvider = (() => {
  const stakePoolSearchProviderName = process.env.STAKE_POOL_SEARCH_PROVIDER;
  if (stakePoolSearchProviderName === 'stub') {
    return createStubStakePoolSearchProvider();
  }
  throw new Error(`STAKE_POOL_SEARCH_PROVIDER unsupported: ${stakePoolSearchProviderName}`);
})();
