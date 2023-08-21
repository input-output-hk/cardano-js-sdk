import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  CommunicationType,
  SerializableTrezorKeyAgentData,
  TrezorKeyAgent,
  util
} from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { CML, Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { PersonalWallet, setupWallet } from '../../../src';
import { dummyLogger as logger } from 'ts-log';
import { mockKeyAgentDependencies } from '../../../../key-management/test/mocks';

describe('TrezorKeyAgent', () => {
  let keyAgent: TrezorKeyAgent;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let wallet: PersonalWallet;
  const trezorConfig = {
    communicationType: CommunicationType.Node,
    manifest: {
      appUrl: 'https://your.application.com',
      email: 'email@developer.com'
    }
  };

  beforeAll(async () => {
    txSubmitProvider = mocks.mockTxSubmitProvider();
    ({ keyAgent, wallet } = await setupWallet({
      bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
      createKeyAgent: async (dependencies) =>
        await TrezorKeyAgent.createWithDevice(
          {
            chainId: Cardano.ChainIds.LegacyTestnet,
            trezorConfig
          },
          dependencies
        ),
      createWallet: async (trezorKeyAgent) => {
        const { address, rewardAccount } = await trezorKeyAgent.deriveAddress(
          { index: 0, type: AddressType.External },
          0
        );
        const assetProvider = mocks.mockAssetProvider();
        const stakePoolProvider = createStubStakePoolProvider();
        const networkInfoProvider = mocks.mockNetworkInfoProvider();
        const utxoProvider = mocks.mockUtxoProvider({ address });
        const rewardsProvider = mocks.mockRewardsProvider({ rewardAccount });
        const chainHistoryProvider = mocks.mockChainHistoryProvider({ rewardAccount });
        const asyncKeyAgent = util.createAsyncKeyAgent(trezorKeyAgent);
        return new PersonalWallet(
          { name: 'HW Wallet' },
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
      },
      logger
    }));
  });

  afterAll(() => wallet.shutdown());

  it('can be created with any account index', async () => {
    const trezorKeyAgentWithRandomIndex = await TrezorKeyAgent.createWithDevice(
      {
        accountIndex: 5,
        chainId: Cardano.ChainIds.LegacyTestnet,
        trezorConfig
      },
      mockKeyAgentDependencies()
    );
    expect(trezorKeyAgentWithRandomIndex).toBeInstanceOf(TrezorKeyAgent);
    expect(trezorKeyAgentWithRandomIndex.accountIndex).toEqual(5);
    expect(trezorKeyAgentWithRandomIndex.extendedAccountPublicKey).not.toEqual(keyAgent.extendedAccountPublicKey);
  });

  test('__typename', () => {
    expect(typeof keyAgent.serializableData.__typename).toBe('string');
  });

  test('chainId', () => {
    expect(keyAgent.chainId).toBe(Cardano.ChainIds.LegacyTestnet);
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

  describe('sign transaction', () => {
    const outputs = [
      {
        address: Cardano.PaymentAddress(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 11_111_111n }
      },
      {
        address: Cardano.PaymentAddress(
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ),
        value: {
          assets: new Map([[AssetId.TSLA, 6n]]),
          coins: 5n
        }
      }
    ];
    const props: InitializeTxProps = {
      outputs: new Set<Cardano.TxOut>(outputs)
    };
    let txInternals: InitializeTxResult;

    beforeAll(async () => {
      txInternals = await wallet.initializeTx(props);
    });

    it('successfully signs a transaction with assets and validity interval', async () => {
      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('throws if signed transaction hash doesnt match hash computed by the wallet', async () => {
      await expect(
        keyAgent.signTransaction({
          body: txInternals.body,
          hash: 'non-matching' as unknown as Cardano.TransactionId
        })
      ).rejects.toThrow();
    });
  });

  describe('serializableData', () => {
    let serializableData: SerializableTrezorKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as SerializableTrezorKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.chainId).toBe('object');
      expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
      expect(Array.isArray(serializableData.knownAddresses)).toBe(true);
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });
});
