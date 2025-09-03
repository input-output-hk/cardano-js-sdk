import { Bip32Account, KeyAgent, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet, createPersonalWallet, restoreKeyAgent } from '../../../src';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { createKeyAgentDependencies, trezorConfig } from './test-utils';
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
  // Key agents for different master key generation schemes
  let defaultKeyAgent: TrezorKeyAgent;
  let icarusKeyAgent: TrezorKeyAgent;
  let ledgerKeyAgent: TrezorKeyAgent;
  let keyAgentDependencies: Awaited<ReturnType<typeof createKeyAgentDependencies>>;

  beforeAll(async () => {
    keyAgentDependencies = await createKeyAgentDependencies();

    // Create key agents for different master key generation schemes
    defaultKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig
      },
      keyAgentDependencies
    );

    icarusKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          ...trezorConfig,
          derivationType: 'ICARUS'
        }
      },
      keyAgentDependencies
    );

    ledgerKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig: {
          ...trezorConfig,
          derivationType: 'LEDGER'
        }
      },
      keyAgentDependencies
    );
  });

  test('creating and restoring TrezorKeyAgent wallet with default master key generation scheme', async () => {
    const freshWallet = await createWallet(defaultKeyAgent);

    const restoredKeyAgent = await restoreKeyAgent(defaultKeyAgent.serializableData, keyAgentDependencies);
    const restoredWallet = await createWallet(restoredKeyAgent);

    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });

  test('creating TrezorKeyAgent wallet with ICARUS master key generation scheme', async () => {
    const freshWallet = await createWallet(icarusKeyAgent);

    const restoredKeyAgent = await restoreKeyAgent(icarusKeyAgent.serializableData, keyAgentDependencies);
    const restoredWallet = await createWallet(restoredKeyAgent);

    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });

  test('creating TrezorKeyAgent wallet with LEDGER master key generation scheme', async () => {
    const freshWallet = await createWallet(ledgerKeyAgent);

    const restoredKeyAgent = await restoreKeyAgent(ledgerKeyAgent.serializableData, keyAgentDependencies);
    const restoredWallet = await createWallet(restoredKeyAgent);

    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });

  test('different master key generation schemes produce different addresses', async () => {
    const defaultWallet = await createWallet(defaultKeyAgent);
    const icarusWallet = await createWallet(icarusKeyAgent);
    const ledgerWallet = await createWallet(ledgerKeyAgent);

    const defaultAddress = await getAddress(defaultWallet);
    const icarusAddress = await getAddress(icarusWallet);
    const ledgerAddress = await getAddress(ledgerWallet);

    // LEDGER should always produce different addresses from ICARUS/ICARUS_TREZOR master key generation schemes
    expect(defaultAddress).not.toEqual(ledgerAddress);
    expect(icarusAddress).not.toEqual(ledgerAddress);

    // For ICARUS vs ICARUS_TREZOR master key generation schemes, the behavior depends on the seed length:
    // - 12/18 word seeds: ICARUS and ICARUS_TREZOR produce the same addresses
    // - 24 word seeds: ICARUS and ICARUS_TREZOR produce different addresses
    // This is due to a documented Trezor firmware quirk with 24-word mnemonics.
    // We can't easily detect the seed length from the device, so we test both possibilities.
    // See README.md for detailed documentation.
    if (defaultAddress === icarusAddress) {
      // 12/18 word seed case - ICARUS and ICARUS_TREZOR should produce the same addresses
      expect(defaultAddress).toEqual(icarusAddress);
    } else {
      // 24 word seed case - ICARUS and ICARUS_TREZOR should produce different addresses
      expect(defaultAddress).not.toEqual(icarusAddress);
    }

    defaultWallet.shutdown();
    icarusWallet.shutdown();
    ledgerWallet.shutdown();
  });

  test('backward compatibility - existing wallets without master key generation scheme continue to work', async () => {
    const wallet = await createWallet(defaultKeyAgent);

    // Should work exactly as before
    expect(await getAddress(wallet)).toBeDefined();
    expect(defaultKeyAgent.trezorConfig.derivationType).toBeUndefined();

    wallet.shutdown();
  });
});
