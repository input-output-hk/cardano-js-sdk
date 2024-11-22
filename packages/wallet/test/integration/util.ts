import { Bip32Account, util } from '@cardano-sdk/key-management';
import { WalletStores } from '../../src/persistence';
import { createPersonalWallet } from '../../src';
import { createStubStakePoolProvider, mockProviders } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';

const {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider,
  mockDrepProvider
} = mockProviders;

const createDefaultProviders = () => ({
  assetProvider: mockAssetProvider(),
  chainHistoryProvider: mockChainHistoryProvider(),
  drepProvider: mockDrepProvider(),
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

export const createWallet = async (stores?: WalletStores, providers: Providers = {}) => {
  const keyAgent = await testAsyncKeyAgent();
  const wallet = createPersonalWallet(
    { name: 'Test Wallet' },
    {
      ...createDefaultProviders(),
      ...providers,
      bip32Account: await Bip32Account.fromAsyncKeyAgent(keyAgent),
      logger,
      stores,
      witnesser: util.createBip32Ed25519Witnesser(keyAgent)
    }
  );
  return { keyAgent, wallet };
};
