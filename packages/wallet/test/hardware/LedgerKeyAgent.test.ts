/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import * as mocks from '../mocks';
import {
  AddressType,
  CommunicationType,
  LedgerKeyAgent,
  LedgerTransportType,
  SerializableLedgerKeyAgentData,
  util
} from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { CML, Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult, SingleAddressWallet, setupWallet } from '../../src';
import { dummyLogger as logger } from 'ts-log';
import { mockKeyAgentDependencies } from '../../../key-management/test/mocks';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';

describe('LedgerKeyAgent', () => {
  let keyAgent: LedgerKeyAgent;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let wallet: SingleAddressWallet;

  beforeAll(async () => {
    txSubmitProvider = mocks.mockTxSubmitProvider();
    ({ keyAgent, wallet } = await setupWallet({
      bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
      createKeyAgent: async (dependencies) =>
        await LedgerKeyAgent.createWithDevice(
          {
            chainId: Cardano.ChainIds.LegacyTestnet,
            communicationType: CommunicationType.Node
          },
          dependencies
        ),
      createWallet: async (ledgerKeyAgent) => {
        const { address, rewardAccount } = await ledgerKeyAgent.deriveAddress({ index: 0, type: AddressType.External });
        const assetProvider = mocks.mockAssetProvider();
        const stakePoolProvider = createStubStakePoolProvider();
        const networkInfoProvider = mocks.mockNetworkInfoProvider();
        const utxoProvider = mocks.mockUtxoProvider({ address });
        const rewardsProvider = mocks.mockRewardsProvider({ rewardAccount });
        const chainHistoryProvider = mocks.mockChainHistoryProvider({ rewardAccount });
        const asyncKeyAgent = util.createAsyncKeyAgent(ledgerKeyAgent);
        return new SingleAddressWallet(
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
    const ledgerKeyAgentWithRandomIndex = await LedgerKeyAgent.createWithDevice(
      {
        accountIndex: 5,
        chainId: Cardano.ChainIds.LegacyTestnet,
        communicationType: CommunicationType.Node,
        deviceConnection: keyAgent.deviceConnection
      },
      mockKeyAgentDependencies()
    );
    expect(ledgerKeyAgentWithRandomIndex).toBeInstanceOf(LedgerKeyAgent);
    expect(ledgerKeyAgentWithRandomIndex.accountIndex).toEqual(5);
    expect(ledgerKeyAgentWithRandomIndex.extendedAccountPublicKey).not.toEqual(keyAgent.extendedAccountPublicKey);
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

  describe('signTransaction', () => {
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
    const props: InitializeTxProps = {
      options: {
        validityInterval: {
          invalidBefore: Cardano.Slot(1),
          invalidHereafter: Cardano.Slot(999_999_999)
        }
      },
      outputs: new Set<Cardano.TxOut>(outputs)
    };
    let txInternals: InitializeTxResult;

    beforeAll(async () => {
      txInternals = await wallet.initializeTx(props);
    });

    it('successfully signs a transaction with assets and validity interval', async () => {
      const signatures = await keyAgent.signTransaction(txInternals);
      expect(signatures.size).toBe(2);
    });

    it('throws if signed transaction hash doesnt match hash computed by the wallet', async () => {
      await expect(
        keyAgent.signTransaction({
          ...txInternals,
          hash: 'non-matching' as unknown as Cardano.TransactionId
        })
      ).rejects.toThrow();
    });
  });

  describe('establish, check and re-establish device connection', () => {
    let deviceConnection: DeviceConnection;
    beforeAll(async () => {
      if (keyAgent.deviceConnection) {
        keyAgent.deviceConnection.transport.close();
      }
      deviceConnection = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);
    });

    it('can check active device connection', async () => {
      const activeDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(
        CommunicationType.Node,
        deviceConnection
      );
      expect(activeDeviceConnection).toBeDefined();
      expect(typeof activeDeviceConnection).toBe('object');
      activeDeviceConnection.transport.close();
    });

    it('can re-establish closed device connection', async () => {
      if (deviceConnection) {
        deviceConnection.transport.close();
      }
      const activeDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(CommunicationType.Node);
      expect(activeDeviceConnection).toBeDefined();
      expect(typeof activeDeviceConnection).toBe('object');
      activeDeviceConnection.transport.close();
    });
  });

  describe('create device connection with transport', () => {
    let transport: LedgerTransportType;
    beforeAll(async () => {
      transport = await LedgerKeyAgent.createTransport({
        communicationType: CommunicationType.Node
      });
    });

    it('can create device connection with activeTransport', async () => {
      const activeDeviceConnection = await LedgerKeyAgent.createDeviceConnection(transport);
      expect(activeDeviceConnection).toBeDefined();
      expect(typeof activeDeviceConnection).toBe('object');
      activeDeviceConnection.transport.close();
    });
  });

  describe('serializableData', () => {
    let serializableData: SerializableLedgerKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as SerializableLedgerKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.chainId).toBe('object');
      expect(Array.isArray(serializableData.knownAddresses)).toBe(true);
      expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
      expect(typeof serializableData.communicationType).toBe('string');
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });
});
