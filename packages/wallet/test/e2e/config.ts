import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostTxSubmitProvider,
  blockfrostWalletProvider
} from '@cardano-sdk/blockfrost';
import { Cardano, testnetTimeSettings } from '@cardano-sdk/core';
import { InMemoryKeyAgent } from '../../src/KeyManagement';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';

const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');
const isTestnet = networkId === 0;

export const walletProvider = (() => {
  const walletProviderName = process.env.WALLET_PROVIDER;
  if (walletProviderName === 'blockfrost') {
    const projectId = process.env.BLOCKFROST_API_KEY;
    if (!projectId) throw new Error('BLOCKFROST_API_KEY not set');
    const blockfrost = new BlockFrostAPI({ isTestnet, projectId });
    return blockfrostWalletProvider(blockfrost);
  }
  throw new Error(`WALLET_PROVIDER unsupported: ${walletProviderName}`);
})();

export const assetProvider = (() => {
  const projectId = process.env.BLOCKFROST_API_KEY;
  if (!projectId) throw new Error('BLOCKFROST_API_KEY not set (for assetProvider)');
  const blockfrost = new BlockFrostAPI({ isTestnet, projectId });
  return blockfrostAssetProvider(blockfrost);
})();

export const txSubmitProvider = (() => {
  const projectId = process.env.BLOCKFROST_API_KEY;
  if (!projectId) throw new Error('BLOCKFROST_API_KEY not set (for txSubmitProvider)');
  const blockfrost = new BlockFrostAPI({ isTestnet, projectId });
  return blockfrostTxSubmitProvider(blockfrost);
})();

export const keyAgentReady = (() => {
  const mnemonicWords = (process.env.MNEMONIC_WORDS || '').split(' ');
  if (mnemonicWords.length === 0) throw new Error('MNEMONIC_WORDS not set');
  const password = process.env.WALLET_PASSWORD;
  if (!password) throw new Error('WALLET_PASSWORD not set');
  return InMemoryKeyAgent.fromBip39MnemonicWords({
    getPassword: async () => Buffer.from(password),
    mnemonicWords,
    networkId
  });
})();

export const stakePoolSearchProvider = (() => {
  const stakePoolSearchProviderName = process.env.STAKE_POOL_SEARCH_PROVIDER;
  if (stakePoolSearchProviderName === 'stub') {
    return createStubStakePoolSearchProvider();
  }
  throw new Error(`STAKE_POOL_SEARCH_PROVIDER unsupported: ${stakePoolSearchProviderName}`);
})();

export const timeSettingsProvider = (() => {
  const timeSettingsProviderName = process.env.TIME_SETTINGS_PROVIDER;
  if (timeSettingsProviderName === 'stub_testnet') {
    return createStubTimeSettingsProvider(testnetTimeSettings);
  }
  throw new Error(`TIME_SETTINGS_PROVIDER unsupported: ${timeSettingsProviderName}`);
})();

if (!process.env.POOL_ID_1) throw new Error('POOL_ID_1 not set');
export const poolId1 = Cardano.PoolId(process.env.POOL_ID_1!);

if (!process.env.POOL_ID_2) throw new Error('POOL_ID_2 not set');
export const poolId2 = Cardano.PoolId(process.env.POOL_ID_2!);
