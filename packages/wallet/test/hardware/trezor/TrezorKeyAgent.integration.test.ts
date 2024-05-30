import * as Crypto from '@cardano-sdk/crypto';
import { Bip32Account, CommunicationType, KeyAgent, KeyPurpose, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet, createPersonalWallet, restoreKeyAgent } from '../../../src';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
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

const keyAgentDependencies = { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), logger };

const createWallet = async (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const stakePoolProvider = createStubStakePoolProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  const rewardsProvider = mockRewardsProvider();
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  const chainHistoryProvider = mockChainHistoryProvider();
  return createPersonalWallet(
    { name: 'Wallet1', purpose: KeyPurpose.STANDARD },
    {
      assetProvider,
      bip32Account: await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent),
      chainHistoryProvider,
      logger,
      networkInfoProvider,
      rewardsProvider,
      stakePoolProvider,
      txSubmitProvider,
      utxoProvider,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    }
  );
};

const getAddress = async (wallet: ObservableWallet) => (await firstValueFrom(wallet.addresses$))[0].address;

describe('TrezorKeyAgent+BaseWallet', () => {
  test('creating and restoring TrezorKeyAgent wallet', async () => {
    const freshKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.STANDARD,
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
