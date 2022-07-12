import { SingleAddressWallet, setupWallet } from '../../src';
import { WalletStores } from '../../src/persistence';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider,
  testAsyncKeyAgent
} from '../mocks';

export const createWallet = async (stores?: WalletStores) =>
  setupWallet({
    createKeyAgent: (dependencies) => testAsyncKeyAgent(undefined, dependencies),
    createWallet: async (keyAgent) => {
      const txSubmitProvider = mockTxSubmitProvider();
      const stakePoolProvider = createStubStakePoolProvider();
      const networkInfoProvider = mockNetworkInfoProvider();
      const assetProvider = mockAssetProvider();
      const utxoProvider = mockUtxoProvider();
      const chainHistoryProvider = mockChainHistoryProvider();
      const rewardsProvider = mockRewardsProvider();
      return new SingleAddressWallet(
        { name: 'Test Wallet' },
        {
          assetProvider,
          chainHistoryProvider,
          keyAgent,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          stores,
          txSubmitProvider,
          utxoProvider
        }
      );
    }
  });
