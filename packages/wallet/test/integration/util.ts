import { SingleAddressWallet, setupWallet } from '../../src';
import { WalletStores } from '../../src/persistence';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';
import {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider
} from '../mocks';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';

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
          keyAgent,
          logger,
          providers: {
            assetProvider,
            chainHistoryProvider,
            networkInfoProvider,
            rewardsProvider,
            stakePoolProvider,
            txSubmitProvider,
            utxoProvider
          },
          stores
        }
      );
    }
  });
