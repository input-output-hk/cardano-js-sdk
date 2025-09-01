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
  let keyAgentDependencies: { bip32Ed25519: Crypto.Bip32Ed25519; logger: typeof logger };

  const TEST_APP_URL = 'https://your.application.com';
  const TEST_EMAIL = 'email@developer.com';

  beforeAll(async () => {
    keyAgentDependencies = { bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(), logger };
  });

  test('creating and restoring TrezorKeyAgent wallet with default derivation type', async () => {
    const freshKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          communicationType: CommunicationType.Node,
          manifest: {
            appUrl: TEST_APP_URL,
            email: TEST_EMAIL
          }
          // No derivationType specified - uses Trezor's default (ICARUS_TREZOR)
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

  test('creating TrezorKeyAgent wallet with ICARUS derivation type', async () => {
    const freshKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          communicationType: CommunicationType.Node,
          derivationType: 'ICARUS',
          manifest: {
            appUrl: TEST_APP_URL,
            email: TEST_EMAIL
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

  test('creating TrezorKeyAgent wallet with LEDGER derivation type', async () => {
    const freshKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          communicationType: CommunicationType.Node,
          derivationType: 'LEDGER',
          manifest: {
            appUrl: TEST_APP_URL,
            email: TEST_EMAIL
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

  test('different derivation types produce different addresses', async () => {
    const defaultKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          communicationType: CommunicationType.Node,
          manifest: {
            appUrl: TEST_APP_URL,
            email: TEST_EMAIL
          }
        }
      },
      keyAgentDependencies
    );

    const icarusKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          communicationType: CommunicationType.Node,
          derivationType: 'ICARUS',
          manifest: {
            appUrl: TEST_APP_URL,
            email: TEST_EMAIL
          }
        }
      },
      keyAgentDependencies
    );

    const defaultWallet = await createWallet(defaultKeyAgent);
    const icarusWallet = await createWallet(icarusKeyAgent);

    const defaultAddress = await getAddress(defaultWallet);
    const icarusAddress = await getAddress(icarusWallet);

    // Different derivation types should produce different addresses
    expect(defaultAddress).not.toEqual(icarusAddress);

    defaultWallet.shutdown();
    icarusWallet.shutdown();
  });

  test('backward compatibility - existing wallets without derivation type continue to work', async () => {
    // Simulate an existing wallet configuration (no derivationType)
    const existingWalletConfig = {
      chainId: Cardano.ChainIds.Preprod,
      trezorConfig: {
        communicationType: CommunicationType.Node,
        manifest: {
          appUrl: 'https://your.application.com',
          email: 'email@developer.com'
        }
        // No derivationType - this is how existing wallets were configured
      }
    };

    const keyAgent = await TrezorKeyAgent.createWithDevice(existingWalletConfig, keyAgentDependencies);
    const wallet = await createWallet(keyAgent);

    // Should work exactly as before
    expect(await getAddress(wallet)).toBeDefined();
    expect(keyAgent.trezorConfig.derivationType).toBeUndefined();

    wallet.shutdown();
  });
});
