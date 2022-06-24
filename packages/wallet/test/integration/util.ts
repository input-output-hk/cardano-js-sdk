import { SingleAddressWallet } from '../../src';
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

export const createWallet = async () => {
  const keyAgent = await testAsyncKeyAgent();
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
      txSubmitProvider,
      utxoProvider
    }
  );
};
