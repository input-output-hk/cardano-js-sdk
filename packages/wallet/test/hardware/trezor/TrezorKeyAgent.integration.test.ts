import * as Crypto from '@cardano-sdk/crypto';
import { Bip32Account, CommunicationType, KeyAgent, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet, createPersonalWallet, restoreKeyAgent } from '../../../src';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { mockProviders } from '@cardano-sdk/util-dev';

const {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardAccountInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider
} = mockProviders;

const createWallet = async (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  const rewardsProvider = mockRewardsProvider();
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  const chainHistoryProvider = mockChainHistoryProvider();
  const rewardAccountInfoProvider = mockRewardAccountInfoProvider();
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

describe('TrezorKeyAgent+BaseWallet', () => {
  test('creating and restoring TrezorKeyAgent wallet', async () => {
    const keyAgentDependencies = { bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(), logger };

    const freshKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          communicationType: CommunicationType.Node,
          manifest: {
            appUrl: 'https://your.application.com',
            email: 'email@developer.com'
          }
        }
      },
      keyAgentDependencies
    );
    const freshWallet = await createWallet(freshKeyAgent);

    const restoredKeyAgent = await restoreKeyAgent(freshKeyAgent.serializableData, keyAgentDependencies);
    const restoredWallet = await createWallet(restoredKeyAgent);

    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
