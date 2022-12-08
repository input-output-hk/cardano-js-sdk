import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyAgent, TrezorKeyAgent, restoreKeyAgent, util } from '@cardano-sdk/key-management';
import { ObservableWallet, SingleAddressWallet, setupWallet } from '../../src';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider
} from '../mocks';

const createWallet = async (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const stakePoolProvider = createStubStakePoolProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  const rewardsProvider = mockRewardsProvider();
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  const chainHistoryProvider = mockChainHistoryProvider();
  return new SingleAddressWallet(
    { name: 'Wallet1' },
    {
      assetProvider,
      chainHistoryProvider,
      keyAgent: asyncKeyAgent,
      logger,
      networkInfoProvider,
      rewardsProvider,
      stakePoolProvider,
      txSubmitProvider,
      utxoProvider
    }
  );
};

const getAddress = async (wallet: ObservableWallet) => (await firstValueFrom(wallet.addresses$))[0].address;

describe('TrezorKeyAgent+SingleAddressWallet', () => {
  test('creating and restoring TrezorKeyAgent wallet', async () => {
    const { wallet: freshWallet, keyAgent: freshKeyAgent } = await setupWallet({
      createKeyAgent: (dependencies) =>
        TrezorKeyAgent.createWithDevice(
          {
            chainId: Cardano.ChainIds.LegacyTestnet,
            trezorConfig: {
              communicationType: CommunicationType.Node,
              manifest: {
                appUrl: 'https://your.application.com',
                email: 'email@developer.com'
              }
            }
          },
          dependencies
        ),
      createWallet,
      logger
    });
    const { wallet: restoredWallet } = await setupWallet({
      createKeyAgent: (dependencies) => restoreKeyAgent(freshKeyAgent.serializableData, dependencies),
      createWallet,
      logger
    });

    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
