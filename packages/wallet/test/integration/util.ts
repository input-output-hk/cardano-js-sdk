import { SingleAddressWallet } from '../../src';
import { createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';
import {
  mockAssetProvider,
  mockNetworkInfoProvider,
  mockTxSubmitProvider,
  mockUtxoProvider,
  mockWalletProvider,
  testAsyncKeyAgent
} from '../mocks';

export const createWallet = async () => {
  const keyAgent = await testAsyncKeyAgent();
  const txSubmitProvider = mockTxSubmitProvider();
  const walletProvider = mockWalletProvider();
  const stakePoolSearchProvider = createStubStakePoolSearchProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  return new SingleAddressWallet(
    { name: 'Test Wallet' },
    {
      assetProvider,
      keyAgent,
      networkInfoProvider,
      stakePoolSearchProvider,
      txSubmitProvider,
      utxoProvider,
      walletProvider
    }
  );
};
