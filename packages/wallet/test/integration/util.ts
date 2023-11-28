import * as Crypto from '@cardano-sdk/crypto';
import { PersonalWallet, setupWallet } from '../../src';
import { WalletStores } from '../../src/persistence';
import { createStubStakePoolProvider, mockProviders } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { util } from '@cardano-sdk/key-management';

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
    bip32Ed25519: new Crypto.SodiumBip32Ed25519(),
    createKeyAgent: (dependencies) => testAsyncKeyAgent(undefined, dependencies),
    createWallet: async (keyAgent) =>
      new PersonalWallet(
        { name: 'Test Wallet' },
        {
          ...createDefaultProviders(),
          ...providers,
          addressManager: util.createBip32Ed25519AddressManager(keyAgent),
          logger,
          stores,
          witnesser: util.createBip32Ed25519Witnesser(keyAgent)
        }
      ),
    logger
  });
