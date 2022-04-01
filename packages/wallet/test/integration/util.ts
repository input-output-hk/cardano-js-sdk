import { SingleAddressWallet } from '../../src';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { mockAssetProvider, mockTxSubmitProvider, mockWalletProvider, testKeyAgent } from '../mocks';
import { testnetTimeSettings } from '@cardano-sdk/core';

export const createWallet = async () => {
  const keyAgent = await testKeyAgent();
  const txSubmitProvider = mockTxSubmitProvider();
  const walletProvider = mockWalletProvider();
  const stakePoolSearchProvider = createStubStakePoolSearchProvider();
  const timeSettingsProvider = createStubTimeSettingsProvider(testnetTimeSettings);
  const assetProvider = mockAssetProvider();
  return new SingleAddressWallet(
    { name: 'Test Wallet' },
    {
      assetProvider,
      keyAgent,
      stakePoolSearchProvider,
      timeSettingsProvider,
      txSubmitProvider,
      walletProvider
    }
  );
};
