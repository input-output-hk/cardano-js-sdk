import * as Crypto from '@cardano-sdk/crypto';

import { Bip32Account, CommunicationType, KeyAgent, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { LedgerKeyAgent } from '@cardano-sdk/hardware-ledger';
import { ObservableWallet, createPersonalWallet, restoreKeyAgent } from '../../../src';
import { firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { mockProviders } from '@cardano-sdk/util-dev';

const {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockRewardAccountInfoProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider
} = mockProviders;

const createWallet = async (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  const rewardAccountInfoProvider = mockRewardAccountInfoProvider();
  const rewardsProvider = mockRewardsProvider();
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  const chainHistoryProvider = mockChainHistoryProvider();

  return createPersonalWallet(
    { name: 'Wallet1' },
    {
      assetProvider,
      bip32Account: await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent),
      chainHistoryProvider,
      logger,
      networkInfoProvider,
      rewardAccountInfoProvider,
      rewardsProvider,
      txSubmitProvider,
      utxoProvider,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    }
  );
};

const getAddress = async (wallet: ObservableWallet) => (await firstValueFrom(wallet.addresses$))[0].address;

describe('LedgerKeyAgent+BaseWallet', () => {
  test('creating and restoring LedgerKeyAgent wallet', async () => {
    const keyAgentDependencies = { bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(), logger };

    const freshKeyAgent = await LedgerKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        communicationType: CommunicationType.Node
      },
      keyAgentDependencies
    );
    const freshWallet = await createWallet(freshKeyAgent);

    const restoredKeyAgent = await restoreKeyAgent(freshKeyAgent.serializableData, keyAgentDependencies);
    const restoredWallet = await createWallet(restoredKeyAgent);

    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    // TODO: finalizeTx with both wallets, assert that signature equals
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
