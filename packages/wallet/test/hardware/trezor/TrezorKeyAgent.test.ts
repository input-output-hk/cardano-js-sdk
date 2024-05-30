import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  Bip32Account,
  CommunicationType,
  KeyPurpose,
  SerializableTrezorKeyAgentData,
  util
} from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { BaseWallet, createPersonalWallet } from '../../../src';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { mockKeyAgentDependencies } from '../../../../key-management/test/mocks';

describe('TrezorKeyAgent', () => {
  let wallet: BaseWallet;
  let trezorKeyAgent: TrezorKeyAgent;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let address: Cardano.PaymentAddress;

  const trezorConfig = {
    communicationType: CommunicationType.Node,
    manifest: {
      appUrl: 'https://your.application.com',
      email: 'email@developer.com'
    }
  };

  beforeAll(async () => {
    txSubmitProvider = mocks.mockTxSubmitProvider();
    trezorKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.STANDARD,
        trezorConfig
      },
      { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), logger }
    );
    const groupedAddress = await trezorKeyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
    address = groupedAddress.address;
    const rewardAccount = groupedAddress.rewardAccount;
    const assetProvider = mocks.mockAssetProvider();
    const stakePoolProvider = createStubStakePoolProvider();
    const networkInfoProvider = mocks.mockNetworkInfoProvider();
    const utxoProvider = mocks.mockUtxoProvider({ address });
    const rewardsProvider = mocks.mockRewardsProvider({ rewardAccount });
    const chainHistoryProvider = mocks.mockChainHistoryProvider({ rewardAccount });
    const asyncKeyAgent = util.createAsyncKeyAgent(trezorKeyAgent);
    wallet = createPersonalWallet(
      { name: 'HW Wallet', purpose: KeyPurpose.STANDARD },
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
  });

  afterAll(() => wallet.shutdown());

  describe('sign transaction', () => {
    const poolId = Cardano.PoolId('pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn');
    const plutusScriptV1: Cardano.PlutusScript = {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
      version: Cardano.PlutusLanguageVersion.V1
    };
    const plutusScriptV2: Cardano.PlutusScript = {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob(
        // eslint-disable-next-line max-len
        '5907620100003232323232323232323232323232332232323232322232325335320193333573466e1cd55cea80124000466442466002006004646464646464646464646464646666ae68cdc39aab9d500c480008cccccccccccc88888888888848cccccccccccc00403403002c02802402001c01801401000c008cd4050054d5d0a80619a80a00a9aba1500b33501401635742a014666aa030eb9405cd5d0a804999aa80c3ae501735742a01066a02803e6ae85401cccd54060081d69aba150063232323333573466e1cd55cea801240004664424660020060046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40a9d69aba15002302b357426ae8940088c98c80b4cd5ce01701681589aab9e5001137540026ae854008c8c8c8cccd5cd19b8735573aa004900011991091980080180119a8153ad35742a00460566ae84d5d1280111931901699ab9c02e02d02b135573ca00226ea8004d5d09aba2500223263202933573805405204e26aae7940044dd50009aba1500533501475c6ae854010ccd540600708004d5d0a801999aa80c3ae200135742a004603c6ae84d5d1280111931901299ab9c026025023135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d55cf280089baa00135742a004601c6ae84d5d1280111931900b99ab9c018017015101613263201633573892010350543500016135573ca00226ea800448c88c008dd6000990009aa80a911999aab9f0012500a233500930043574200460066ae880080508c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00a80a00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500f014357426ae8940088c98c8064cd5ce00d00c80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007006c06406005c4d55cea80089baa00135742a00466a016eb8d5d09aba2500223263201533573802c02a02626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355012223233335573e0044a010466a00e66442466002006004600c6aae754008c014d55cf280118021aba200301213574200222440042442446600200800624464646666ae68cdc3a800a40004642446004006600a6ae84d55cf280191999ab9a3370ea0049001109100091931900819ab9c01101000e00d135573aa00226ea80048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01101000e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00d00c00a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00580500409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a00980880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700340300280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801401200e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7002c02802001c0184d55cea80089baa0012323333573466e1d40052002212200223333573466e1d40092000200823263200633573800e00c00800626aae74dd5000a4c2400292010350543100122001112323001001223300330020020011'
      ),
      version: Cardano.PlutusLanguageVersion.V2
    };
    const collateral = {
      index: 0,
      txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
    };
    const outputs = {
      outputWithAssets: {
        address: Cardano.PaymentAddress(
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ),
        value: {
          assets: new Map([[AssetId.TSLA, 6n]]),
          coins: 5n
        }
      },
      simpleOutput: {
        address: Cardano.PaymentAddress(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 11_111_111n }
      },
      simpleOutputWithDatumHash: {
        address: Cardano.PaymentAddress(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        datumHash: Hash32ByteBase16('b6eb57092c330973b23784ac39426921eebd8376343409c03f613fa1a2017126'),
        value: { coins: 11_111_111n }
      },
      simpleOutputWithInlineDatum: {
        address: Cardano.PaymentAddress(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        datum: 123n,
        value: { coins: 11_111_111n }
      },
      simpleOutputWithReferenceScript: {
        address: Cardano.PaymentAddress(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        datumHash: Hash32ByteBase16('b6eb57092c330973b23784ac39426921eebd8376343409c03f613fa1a2017126'),
        scriptReference: plutusScriptV1,
        value: { coins: 11_111_111n }
      }
    };
    let rewardAccount: Cardano.RewardAccount;
    let props: InitializeTxProps;
    let txInternals: InitializeTxResult;

    beforeEach(async () => {
      rewardAccount = (await firstValueFrom(wallet.addresses$))[0].rewardAccount;
    });

    it('successfully signs simple transaction', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction with assets', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.outputWithAssets])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction with metadata', async () => {
      props = {
        auxiliaryData: { blob: new Map([[123n, '1234']]) },
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction with validityInterval', async () => {
      props = {
        options: {
          validityInterval: {
            invalidBefore: Cardano.Slot(1),
            invalidHereafter: Cardano.Slot(999_999_999)
          }
        },
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction that mints a token', async () => {
      const policyId = Cardano.PolicyId('38299ce86f8cbef9ebeecc2e94370cb49196d60c93797fffb71d3932');
      const assetId = Cardano.AssetId(`${policyId}707572706C65`);
      props = {
        mint: new Map([[assetId, 1n]]),
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs stake registration and delegation transaction', async () => {
      const stakeCredential = {
        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount)),
        type: Cardano.CredentialType.KeyHash
      };

      const stakeRegistrationCert = {
        __typename: Cardano.CertificateType.StakeRegistration,
        stakeCredential
      } as Cardano.StakeAddressCertificate;
      const stakeDelegationCert = {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId,
        stakeCredential
      } as Cardano.StakeDelegationCertificate;

      props = {
        certificates: [stakeRegistrationCert, stakeDelegationCert],
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs stake deregistration transaction', async () => {
      const stakeCredential = {
        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount)),
        type: Cardano.CredentialType.KeyHash
      };

      const stakeDeregistrationCert = {
        __typename: Cardano.CertificateType.StakeDeregistration,
        stakeCredential
      } as Cardano.StakeAddressCertificate;

      props = {
        certificates: [stakeDeregistrationCert],
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it.skip('successfully signs pool registration transaction', async () => {
      const poolRewardAcc = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      const metadataJson = {
        hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
        url: 'https://example.com'
      };
      const vrfVkHex = Cardano.VrfVkHex('198890ad6c92e80fbdab554dda02da9fb49d001bbd96181f3e07f7a6ab0d0640');
      const poolRegistrationCert = {
        __typename: Cardano.CertificateType.PoolRegistration,
        poolParameters: {
          cost: 340_000_000n,
          id: poolId,
          margin: { denominator: 2, numerator: 1 },
          metadataJson,
          owners: [rewardAccount, poolRewardAcc],
          pledge: 500_000_000n,
          relays: [],
          rewardAccount: poolRewardAcc,
          vrf: vrfVkHex
        }
      } as Cardano.PoolRegistrationCertificate;
      props = {
        certificates: [poolRegistrationCert],
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('throws if signed transaction hash doesnt match hash computed by the wallet', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);
      await expect(
        trezorKeyAgent.signTransaction(
          {
            body: txInternals.body,
            hash: 'non-matching' as unknown as Cardano.TransactionId
          },
          { knownAddresses: await firstValueFrom(wallet.addresses$), purpose: KeyPurpose.STANDARD, txInKeyPathMap: {} }
        )
      ).rejects.toThrow();
    });

    it('successfully signs simple transaction with datum hash', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutputWithDatumHash])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs simple transaction with inline datum', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutputWithInlineDatum])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs simple transaction with reference script', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutputWithReferenceScript])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs transaction with collaterals', async () => {
      props = {
        collaterals: new Set([collateral]),
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutputWithReferenceScript])
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs transaction that mints a token using a plutus script', async () => {
      // Script minting policy id.
      const policyId = Cardano.PolicyId('38299ce86f8cbef9ebeecc2e94370cb49196d60c93797fffb71d3932');
      const assetId = Cardano.AssetId(`${policyId}707572706C65`);

      const scriptRedeemer: Cardano.Redeemer = {
        // CBOR for Void redeemer.
        data: Serialization.PlutusData.fromCbor(HexBlob('d8799fff')).toCore(),
        executionUnits: {
          memory: 13_421_562,
          steps: 9_818_438_928
        },
        // Hardcoded to 0 since we only have one script
        index: 0,
        purpose: Cardano.RedeemerPurpose.mint
      };

      const txProps: InitializeTxProps = {
        collaterals: new Set([collateral]),
        mint: new Map([[assetId, 1n]]),
        outputs: new Set([outputs.simpleOutput, outputs.outputWithAssets]),
        witness: { redeemers: [scriptRedeemer], scripts: [plutusScriptV2] }
      };

      txInternals = await wallet.initializeTx(txProps);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs transaction with required extra signatures', async () => {
      const requiredExtraSignatures = [
        // Unknown payments address -> keyHash
        Crypto.Ed25519KeyHashHex('9ab1e9d2346c3f4be360d22b8ee7756a0316c3c1aece473e2887ea97')
      ];
      // Add known payment address if exists -> keyPath (acc0)
      const knownAddressPaymentCredential = Cardano.Address.fromBech32(address)?.asBase()?.getPaymentCredential().hash;
      if (knownAddressPaymentCredential)
        requiredExtraSignatures.push(Crypto.Ed25519KeyHashHex(knownAddressPaymentCredential));

      props = {
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput]),
        requiredExtraSignatures
      };
      txInternals = await wallet.initializeTx(props);

      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: txInternals });
      expect(signatures.size).toBe(2);
    });

    it('can sign multi-delegation transaction', async () => {
      const poolId1 = Cardano.PoolId('pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn');
      const poolId2 = Cardano.PoolId('pool1z5uqdk7dzdxaae5633fqfcu2eqzy3a3rgtuvy087fdld7yws0xt');

      const txBuilder = wallet.createTxBuilder();
      const builtTx = await txBuilder
        .delegatePortfolio({
          name: 'Trezor multi-delegation Portfolio',
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId1)),
              weight: 1
            },
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId2)),
              weight: 2
            }
          ]
        })
        .build()
        .inspect();
      const {
        witness: { signatures }
      } = await wallet.finalizeTx({ tx: builtTx });
      expect(signatures.size).toBe(3);
    });
  });

  it('can be created with any account index', async () => {
    const trezorKeyAgentWithRandomIndex = await TrezorKeyAgent.createWithDevice(
      {
        accountIndex: 5,
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.STANDARD,
        trezorConfig
      },
      mockKeyAgentDependencies()
    );
    expect(trezorKeyAgentWithRandomIndex).toBeInstanceOf(TrezorKeyAgent);
    expect(trezorKeyAgentWithRandomIndex.accountIndex).toEqual(5);
    expect(trezorKeyAgentWithRandomIndex.extendedAccountPublicKey).not.toEqual(trezorKeyAgent.extendedAccountPublicKey);
  });

  test('__typename', () => {
    expect(typeof trezorKeyAgent.serializableData.__typename).toBe('string');
  });

  test('chainId', () => {
    expect(trezorKeyAgent.chainId).toBe(Cardano.ChainIds.Preprod);
  });

  test('accountIndex', () => {
    expect(typeof trezorKeyAgent.accountIndex).toBe('number');
  });

  test('extendedAccountPublicKey', () => {
    expect(typeof trezorKeyAgent.extendedAccountPublicKey).toBe('string');
  });

  describe('serializableData', () => {
    let serializableData: SerializableTrezorKeyAgentData;

    beforeEach(() => {
      serializableData = trezorKeyAgent.serializableData as SerializableTrezorKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.chainId).toBe('object');
      expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });
});
