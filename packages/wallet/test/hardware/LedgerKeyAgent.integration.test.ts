import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyAgent, LedgerKeyAgent, restoreKeyAgent, util } from '@cardano-sdk/key-management';
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

describe('LedgerKeyAgent+SingleAddressWallet', () => {
  test('creating and restoring LedgerKeyAgent wallet', async () => {
    const { wallet: freshWallet, keyAgent: freshKeyAgent } = await setupWallet({
      createKeyAgent: (dependencies) =>
        LedgerKeyAgent.createWithDevice(
          {
            communicationType: CommunicationType.Node,
            networkId: Cardano.NetworkId.testnet,
            protocolMagic: 1_097_911_063
          },
          dependencies
        ),
      createWallet
    });
    const { wallet: restoredWallet } = await setupWallet({
      createKeyAgent: (dependencies) => restoreKeyAgent(freshKeyAgent.serializableData, dependencies),
      createWallet
    });
    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    // TODO: finalizeTx with both wallets, assert that signature equals
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
