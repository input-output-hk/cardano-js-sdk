/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, CommunicationType, SerializableLedgerKeyAgentData, util } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { CML, Cardano } from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { LedgerKeyAgent, LedgerTransportType } from '@cardano-sdk/hardware-ledger';
import { PersonalWallet, setupWallet } from '../../../src';
import { dummyLogger as logger } from 'ts-log';
import { mockKeyAgentDependencies } from '../../../../key-management/test/mocks';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';

describe('LedgerKeyAgent', () => {
  let keyAgent: LedgerKeyAgent;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let wallet: PersonalWallet;

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
        const { address, rewardAccount } = await ledgerKeyAgent.deriveAddress(
          { index: 0, type: AddressType.External },
          0
        );
        const assetProvider = mocks.mockAssetProvider();
        const stakePoolProvider = createStubStakePoolProvider();
        const networkInfoProvider = mocks.mockNetworkInfoProvider();
        const utxoProvider = mocks.mockUtxoProvider({ address });
        const rewardsProvider = mocks.mockRewardsProvider({ rewardAccount });
        const chainHistoryProvider = mocks.mockChainHistoryProvider({ rewardAccount });
        const asyncKeyAgent = util.createAsyncKeyAgent(ledgerKeyAgent);
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
          assets: new Map([
            [AssetId.PXL, 10n],
            [AssetId.TSLA, 6n]
          ]),
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

    it('can sign a transaction that mints a token using a plutus script', async () => {
      const script: Cardano.PlutusScript = {
        __type: Cardano.ScriptType.Plutus,
        bytes: HexBlob(
          // eslint-disable-next-line max-len
          '5907620100003232323232323232323232323232332232323232322232325335320193333573466e1cd55cea80124000466442466002006004646464646464646464646464646666ae68cdc39aab9d500c480008cccccccccccc88888888888848cccccccccccc00403403002c02802402001c01801401000c008cd4050054d5d0a80619a80a00a9aba1500b33501401635742a014666aa030eb9405cd5d0a804999aa80c3ae501735742a01066a02803e6ae85401cccd54060081d69aba150063232323333573466e1cd55cea801240004664424660020060046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40a9d69aba15002302b357426ae8940088c98c80b4cd5ce01701681589aab9e5001137540026ae854008c8c8c8cccd5cd19b8735573aa004900011991091980080180119a8153ad35742a00460566ae84d5d1280111931901699ab9c02e02d02b135573ca00226ea8004d5d09aba2500223263202933573805405204e26aae7940044dd50009aba1500533501475c6ae854010ccd540600708004d5d0a801999aa80c3ae200135742a004603c6ae84d5d1280111931901299ab9c026025023135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d55cf280089baa00135742a004601c6ae84d5d1280111931900b99ab9c018017015101613263201633573892010350543500016135573ca00226ea800448c88c008dd6000990009aa80a911999aab9f0012500a233500930043574200460066ae880080508c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00a80a00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500f014357426ae8940088c98c8064cd5ce00d00c80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007006c06406005c4d55cea80089baa00135742a00466a016eb8d5d09aba2500223263201533573802c02a02626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355012223233335573e0044a010466a00e66442466002006004600c6aae754008c014d55cf280118021aba200301213574200222440042442446600200800624464646666ae68cdc3a800a40004642446004006600a6ae84d55cf280191999ab9a3370ea0049001109100091931900819ab9c01101000e00d135573aa00226ea80048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01101000e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00d00c00a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00580500409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a00980880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700340300280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801401200e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7002c02802001c0184d55cea80089baa0012323333573466e1d40052002212200223333573466e1d40092000200823263200633573800e00c00800626aae74dd5000a4c2400292010350543100122001112323001001223300330020020011'
        ),
        version: Cardano.PlutusLanguageVersion.V2
      };

      // Script minting policy id.
      const policyId = Cardano.PolicyId('38299ce86f8cbef9ebeecc2e94370cb49196d60c93797fffb71d3932');
      const scriptRedeemer: Cardano.Redeemer = {
        // CBOR for Void redeemer.
        data: HexBlob('d8799fff'),
        executionUnits: {
          memory: 13_421_562,
          steps: 9_818_438_928
        },
        // Hardcoded to 0 since we only have one script
        index: 0,
        purpose: Cardano.RedeemerPurpose.mint
      };

      // Script data hash was precomputed with the CML (hash of datums, redeemers and language views).
      const scriptDataHash = Hash32ByteBase16('b6eb57092c330973b23784ac39426921eebd8376343409c03f613fa1a2017126');

      const assetId = Cardano.AssetId(`${policyId}707572706C65`);
      const tokens = new Map([[assetId, 1n]]);

      const txProps: InitializeTxProps = {
        collaterals: new Set([
          {
            index: 0,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          }
        ]),
        mint: tokens,
        options: {
          validityInterval: {
            invalidBefore: undefined,
            invalidHereafter: undefined
          }
        },
        outputs: new Set([
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
        ]),
        scriptIntegrityHash: scriptDataHash,
        witness: { redeemers: [scriptRedeemer], scripts: [script] }
      };

      const unsignedTx = await wallet.initializeTx(txProps);

      const signatures = await keyAgent.signTransaction(unsignedTx);
      expect(signatures.size).toBe(2);
    });
  });

  describe('deviceConnections persistence', () => {
    let transportSpy: jest.SpyInstance;
    beforeAll(async () => {
      transportSpy = jest.spyOn(LedgerKeyAgent, 'createTransport');

      if (keyAgent.deviceConnection) {
        await keyAgent.deviceConnection.transport.close();
        LedgerKeyAgent.deviceConnections = [];
      }
    });

    afterEach(() => {
      LedgerKeyAgent.deviceConnections = [];
      transportSpy.mockClear();
    });

    it('should return an existing connection if one exists', async () => {
      LedgerKeyAgent.deviceConnections = [];
      const connection1 = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);
      const connection2 = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);

      expect(transportSpy).toHaveBeenCalledTimes(1);

      expect(connection1).toBe(connection2);
      await connection2.transport.close();
    });

    it('should create a new connection if none match the requested parameters', async () => {
      LedgerKeyAgent.deviceConnections = [
        {
          communicationType: CommunicationType.Web,
          deviceConnection: {} as any
        }
      ];
      const connection = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);

      expect(transportSpy).toHaveBeenCalledTimes(1);
      await connection.transport.close();
    });

    it('should create a new connection if none are available', async () => {
      LedgerKeyAgent.deviceConnections = [];
      const connection = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);

      expect(transportSpy).toHaveBeenCalledTimes(1);
      await connection.transport.close();
    });
  });

  describe('establish, check and re-establish device connection', () => {
    let deviceConnection: DeviceConnection;
    beforeAll(async () => {
      if (keyAgent.deviceConnection) {
        await keyAgent.deviceConnection.transport.close();
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
      await activeDeviceConnection.transport.close();
    });

    it('can re-establish closed device connection', async () => {
      if (deviceConnection) {
        await deviceConnection.transport.close();
      }
      const activeDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(CommunicationType.Node);
      expect(activeDeviceConnection).toBeDefined();
      expect(typeof activeDeviceConnection).toBe('object');
      await activeDeviceConnection.transport.close();
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
      await activeDeviceConnection.transport.close();
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
