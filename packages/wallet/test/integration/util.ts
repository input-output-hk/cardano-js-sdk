import { SingleAddressWallet } from '../../src';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
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
  const stakePoolProvider = createStubStakePoolProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  return new SingleAddressWallet(
    { name: 'Test Wallet' },
    {
      assetProvider,
      keyAgent,
      networkInfoProvider,
      stakePoolProvider,
      txSubmitProvider,
      utxoProvider,
      walletProvider
    }
  );
};
