import * as Crypto from '@cardano-sdk/crypto';
import { CML } from '@cardano-sdk/core';
import { PersonalWallet, setupWallet } from '../../src';
import { WalletStores } from '../../src/persistence';
import { createStubStakePoolProvider, mockProviders } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';

const {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider
} = mockProviders;

const createDefaultProviders = () => ({
  assetProvider: mockAssetProvider(),
  chainHistoryProvider: mockChainHistoryProvider(),
  networkInfoProvider: mockNetworkInfoProvider(),
  rewardsProvider: mockRewardsProvider(),
  stakePoolProvider: createStubStakePoolProvider(),
  txSubmitProvider: mockTxSubmitProvider(),
  utxoProvider: mockUtxoProvider()
});

type RequiredProviders = ReturnType<typeof createDefaultProviders>;
export type Providers = {
  [k in keyof RequiredProviders]?: RequiredProviders[k];
};

export const createWallet = async (stores?: WalletStores, providers: Providers = {}) =>
  await setupWallet({
    bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
    createKeyAgent: (dependencies) => testAsyncKeyAgent(undefined, dependencies),
    createWallet: async (keyAgent) =>
      new PersonalWallet(
        { name: 'Test Wallet' },
        {
          ...createDefaultProviders(),
          ...providers,
          keyAgent,
          logger,
          stores
        }
      ),
    logger
  });
