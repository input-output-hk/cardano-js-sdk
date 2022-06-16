import * as mocks from '../mocks';
import { AssetId, createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { Cardano } from '@cardano-sdk/core';
import { CommunicationType } from '../../src/KeyManagement/types';
import { KeyManagement, SingleAddressWallet } from '../../src';

describe('TrezorKeyAgent', () => {
  let keyAgent: KeyManagement.TrezorKeyAgent;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let walletProvider: mocks.WalletProviderStub;
  let wallet: SingleAddressWallet;
  const trezorConfig = {
    communicationType: CommunicationType.Node,
    manifest: {
      appUrl: 'https://your.application.com',
      email: 'email@developer.com'
    }
  };

  beforeAll(async () => {
    keyAgent = await KeyManagement.TrezorKeyAgent.createWithDevice({
      networkId: Cardano.NetworkId.testnet,
      protocolMagic: 1_097_911_063,
      trezorConfig
    });
    const groupedAddress: KeyManagement.GroupedAddress = {
      accountIndex: 0,
      address: mocks.utxo[0][0].address,
      index: 0,
      networkId: Cardano.NetworkId.testnet,
      rewardAccount: mocks.rewardAccount,
      type: KeyManagement.AddressType.External
    };
    keyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
    keyAgent.knownAddresses.push(groupedAddress);
    txSubmitProvider = mocks.mockTxSubmitProvider();
    walletProvider = mocks.mockWalletProvider();
    const assetProvider = mocks.mockAssetProvider();
    const stakePoolProvider = createStubStakePoolProvider();
    const networkInfoProvider = mocks.mockNetworkInfoProvider();
    const rewardsProvider = mocks.mockRewardsProvider();
    const chainHistoryProvider = mocks.mockChainHistoryProvider();
    const utxoProvider = mocks.mockUtxoProvider();
    const asyncKeyAgent = KeyManagement.util.createAsyncKeyAgent(keyAgent);
    wallet = new SingleAddressWallet(
      { name: 'Trezor Wallet' },
      {
        assetProvider,
        chainHistoryProvider,
        keyAgent: asyncKeyAgent,
        networkInfoProvider,
        rewardsProvider,
        stakePoolProvider,
        txSubmitProvider,
        utxoProvider,
        walletProvider
      }
    );
  });

  it('can be created with any account index', async () => {
    const trezorKeyAgentWithRandomIndex = await KeyManagement.TrezorKeyAgent.createWithDevice({
      accountIndex: 5,
      networkId: Cardano.NetworkId.testnet,
      protocolMagic: 1_097_911_063,
      trezorConfig
    });
    expect(trezorKeyAgentWithRandomIndex).toBeInstanceOf(KeyManagement.TrezorKeyAgent);
    expect(trezorKeyAgentWithRandomIndex.accountIndex).toEqual(5);
    expect(trezorKeyAgentWithRandomIndex.extendedAccountPublicKey).not.toEqual(keyAgent.extendedAccountPublicKey);
  });

  test('__typename', () => {
    expect(typeof keyAgent.serializableData.__typename).toBe('string');
  });

  test('networkId', () => {
    expect(typeof keyAgent.networkId).toBe('number');
  });

  test('accountIndex', () => {
    expect(typeof keyAgent.accountIndex).toBe('number');
  });

  test('knownAddresses', () => {
    expect(Array.isArray(keyAgent.knownAddresses)).toBe(true);
  });

  test('extendedAccountPublicKey', () => {
    expect(typeof keyAgent.extendedAccountPublicKey).toBe('string');
  });

  test('sign tx', async () => {
    const outputs = [
      {
        address: Cardano.Address(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 11_111_111n }
      },
      {
        address: Cardano.Address(
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ),
        value: {
          assets: new Map([[AssetId.TSLA, 6n]]),
          coins: 5n
        }
      }
    ];
    const props = {
      outputs: new Set<Cardano.TxOut>(outputs)
    };
    const txInternals = await wallet.initializeTx(props);
    const signatures = await keyAgent.signTransaction(
      {
        body: txInternals.body,
        hash: txInternals.hash
      },
      {
        inputAddressResolver: wallet.util.resolveInputAddress
      }
    );
    expect(signatures.size).toBe(1);
  });

  describe('serializableData', () => {
    let serializableData: KeyManagement.SerializableTrezorKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as KeyManagement.SerializableTrezorKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.networkId).toBe('number');
      expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
      expect(Array.isArray(serializableData.knownAddresses)).toBe(true);
      expect(typeof serializableData.protocolMagic).toBe('number');
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });
});
