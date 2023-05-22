import * as Crypto from '@cardano-sdk/crypto';
import { CML, Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyAgent, util } from '@cardano-sdk/key-management';
import { LedgerKeyAgent } from '@cardano-sdk/hardware-ledger';
import { ObservableWallet, PersonalWallet, restoreKeyAgent, setupWallet } from '../../../src';
import { createStubStakePoolProvider, mockProviders } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';

const {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider
} = mockProviders;

const createWallet = async (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const stakePoolProvider = createStubStakePoolProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  const rewardsProvider = mockRewardsProvider();
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  const chainHistoryProvider = mockChainHistoryProvider();
  return new PersonalWallet(
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

describe('LedgerKeyAgent+PersonalWallet', () => {
  test('creating and restoring LedgerKeyAgent wallet', async () => {
    const { wallet: freshWallet, keyAgent: freshKeyAgent } = await setupWallet({
      bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
      createKeyAgent: (dependencies) =>
        LedgerKeyAgent.createWithDevice(
          {
            chainId: Cardano.ChainIds.LegacyTestnet,
            communicationType: CommunicationType.Node
          },
          dependencies
        ),
      createWallet,
      logger
    });
    const { wallet: restoredWallet } = await setupWallet({
      bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
      createKeyAgent: (dependencies) => restoreKeyAgent(freshKeyAgent.serializableData, dependencies),
      createWallet,
      logger
    });
    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    // TODO: finalizeTx with both wallets, assert that signature equals
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
