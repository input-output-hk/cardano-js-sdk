/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  Bip32Account,
  CommunicationType,
  SerializableLedgerKeyAgentData,
  cip8,
  util
} from '@cardano-sdk/key-management';
import { AssetId, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { BaseWallet, createPersonalWallet } from '../../../src';
import { COSEKey, COSESign1, SigStructure } from '@emurgo/cardano-message-signing-nodejs';
import { Cardano, Serialization, util as coreUtils } from '@cardano-sdk/core';
import { HID } from 'node-hid';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { LargeFirstSelector } from '@cardano-sdk/input-selection';
import { LedgerKeyAgent, LedgerTransportType } from '@cardano-sdk/hardware-ledger';
import {
  MockChangeAddressResolver,
  getPayToPubKeyHashScript,
  getPaymentCredential,
  getStakeCredential
} from '../utils';
import { buildDRepAddressFromDRepKey } from '../../util';
import { firstValueFrom } from 'rxjs';
import { getDevices } from '@ledgerhq/hw-transport-node-hid-noevents';
import { dummyLogger as logger } from 'ts-log';
import { mockKeyAgentDependencies } from '../../../../key-management/test/mocks';
import DeviceConnection, { InvalidDataReason } from '@cardano-foundation/ledgerjs-hw-app-cardano';

const getHidDevice = () => {
  const ledgerDevicePath = getDevices()[0]?.path;
  if (!ledgerDevicePath) {
    throw new Error('No ledger device connected');
  }
  return new HID(ledgerDevicePath);
};

const cleanupEstablishedConnections = async () => {
  if (LedgerKeyAgent.deviceConnections.length === 0) return;
  for (const { deviceConnection } of LedgerKeyAgent.deviceConnections) {
    await deviceConnection.transport.close();
  }
  LedgerKeyAgent.deviceConnections = [];
};

const signAndDecode = async (
  signWith: Cardano.PaymentAddress | Cardano.RewardAccount,
  wallet: BaseWallet,
  message = HexBlob('abc123')
) => {
  const dataSignature = await wallet.signData({
    payload: message,
    signWith
  });

  const coseKey = COSEKey.from_bytes(Buffer.from(dataSignature.key, 'hex'));
  const coseSign1 = COSESign1.from_bytes(Buffer.from(dataSignature.signature, 'hex'));

  const publicKeyHeader = coseKey.header(cip8.CoseLabel.x)!;
  const publicKeyBytes = publicKeyHeader.as_bytes()!;
  const publicKeyHex = coreUtils.bytesToHex(publicKeyBytes);
  const signedData = coseSign1.signed_data();

  return { coseKey, coseSign1, publicKeyHex, signedData };
};

const testAddressHeader = (signedData: SigStructure, signWith: Cardano.RewardAccount | Cardano.PaymentAddress) => {
  const addressHeader = signedData.body_protected().deserialized_headers().header(cip8.CoseLabel.address)!;

  // Subject to change (cbor vs raw bytes argument), PR open: https://github.com/cardano-foundation/CIPs/pull/148
  // An alternative would be addressHeader.to_bytes(), although
  // @emurgo/cardano-message-signing-nodejs only allows CBORValue for headers
  const addressHeaderBytes = addressHeader.as_bytes();

  expect(Buffer.from(addressHeaderBytes!).toString('hex')).toBe(Cardano.Address.fromBech32(signWith).toBytes());
};

describe('LedgerKeyAgent', () => {
  describe('general', () => {
    afterEach(cleanupEstablishedConnections);

    it('does a cleanup after device disconnection', async () => {
      const connection = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);
      const transportCloseSpy = jest.spyOn(connection.transport, 'close');
      connection.transport.emit('disconnect');

      expect(transportCloseSpy).toHaveBeenCalledTimes(1);
      expect(LedgerKeyAgent.deviceConnections).toHaveLength(0);

      transportCloseSpy.mockRestore();
    });

    it('allows to establish connection for a specific device', async () => {
      const hidDevice = getHidDevice();
      await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node, hidDevice);

      expect(LedgerKeyAgent.deviceConnections).toHaveLength(1);
      expect(LedgerKeyAgent.deviceConnections[0].device).toBe(hidDevice);
      hidDevice.close();
    });
  });

  describe('instance', () => {
    let ledgerKeyAgent: LedgerKeyAgent;

    beforeAll(async () => {
      ledgerKeyAgent = await LedgerKeyAgent.createWithDevice(
        {
          chainId: Cardano.ChainIds.Preprod,
          communicationType: CommunicationType.Node
        },
        { bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(), logger }
      );
    });

    afterAll(async () => {
      await ledgerKeyAgent.deviceConnection?.transport.close();
    });

    it('can be created with any account index', async () => {
      const ledgerKeyAgentWithRandomIndex = await LedgerKeyAgent.createWithDevice(
        {
          accountIndex: 5,
          chainId: Cardano.ChainIds.Preprod,
          communicationType: CommunicationType.Node,
          deviceConnection: ledgerKeyAgent.deviceConnection
        },
        await mockKeyAgentDependencies()
      );
      expect(ledgerKeyAgentWithRandomIndex).toBeInstanceOf(LedgerKeyAgent);
      expect(ledgerKeyAgentWithRandomIndex.accountIndex).toEqual(5);
      expect(ledgerKeyAgentWithRandomIndex.extendedAccountPublicKey).not.toEqual(
        ledgerKeyAgent.extendedAccountPublicKey
      );
    });

    test('__typename', () => {
      expect(typeof ledgerKeyAgent.serializableData.__typename).toBe('string');
    });

    test('chainId', () => {
      expect(ledgerKeyAgent.chainId).toBe(Cardano.ChainIds.Preprod);
    });

    test('accountIndex', () => {
      expect(typeof ledgerKeyAgent.accountIndex).toBe('number');
    });

    test('extendedAccountPublicKey', () => {
      expect(typeof ledgerKeyAgent.extendedAccountPublicKey).toBe('string');
    });

    describe('signTransaction', () => {
      let txSubmitProvider: mocks.TxSubmitProviderStub;
      let wallet: BaseWallet;
      let txInternals: InitializeTxResult;

      const poolId1 = Cardano.PoolId('pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn');
      const poolId2 = Cardano.PoolId('pool1z5uqdk7dzdxaae5633fqfcu2eqzy3a3rgtuvy087fdld7yws0xt');
      const poolId1Hex = Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId1));
      const poolId2Hex = Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId2));
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

      const byronOutputs = [
        {
          address: Cardano.PaymentAddress('FHnt4NL7yPXtsWVUqTv1Tr1ZSarFUYHS2DFLRUJwtqx8RnpZ8s8JefSYTekFcSF'),
          value: { coins: 11_111_111n }
        }
      ];

      const byronProps: InitializeTxProps = {
        options: {
          validityInterval: {
            invalidBefore: Cardano.Slot(1),
            invalidHereafter: Cardano.Slot(999_999_999)
          }
        },
        outputs: new Set<Cardano.TxOut>(byronOutputs)
      };

      const props: InitializeTxProps = {
        options: {
          validityInterval: {
            invalidBefore: Cardano.Slot(1),
            invalidHereafter: Cardano.Slot(999_999_999)
          }
        },
        outputs: new Set<Cardano.TxOut>(outputs)
      };

      beforeAll(async () => {
        txSubmitProvider = mocks.mockTxSubmitProvider();
        const { address, rewardAccount } = await ledgerKeyAgent.deriveAddress(
          { index: 0, type: AddressType.External },
          0
        );
        const assetProvider = mocks.mockAssetProvider();
        const rewardAccountInfoProvider = mocks.mockRewardAccountInfoProvider();
        const networkInfoProvider = mocks.mockNetworkInfoProvider();
        const utxoProvider = mocks.mockUtxoProvider({ address });
        const rewardsProvider = mocks.mockRewardsProvider({ rewardAccount });
        const chainHistoryProvider = mocks.mockChainHistoryProvider({ rewardAccount });
        const asyncKeyAgent = util.createAsyncKeyAgent(ledgerKeyAgent);
        wallet = createPersonalWallet(
          { name: 'HW Wallet' },
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
        txInternals = await wallet.initializeTx(props);
      });

      afterAll(() => wallet.shutdown());

      it('successfully signs a transaction with assets and validity interval', async () => {
        const {
          witness: { signatures }
        } = await wallet.finalizeTx({ tx: txInternals });
        expect(signatures.size).toBe(2);
      });

      it('successfully signs a transaction with byron address output', async () => {
        const {
          witness: { signatures }
        } = await wallet.finalizeTx({ tx: await wallet.initializeTx(byronProps) });
        expect(signatures.size).toBe(2);
      });

      it('successfully signs ADA handle mint transaction', async () => {
        const cbor =
          '84a500818258207aa1264bcd0c06f34a49ed1dd7307a2bdec5a97bdeb546498759ad5b8ed42fd5010182a200583930195bde3deacb613b7e9eb6280b14db4e353e475e96d19f3f7a5e2d66195bde3deacb613b7e9eb6280b14db4e353e475e96d19f3f7a5e2d66011a00e4e1c0a2005839003d3246dc0c50ab3c74a8ffdd8068313ff99d341c461a8fe31f416d0a8fba06d60d71edc077cc5ebcb8ff82137afbce68df98271909332348011b000000025106a838021a00029309031a04a07bc6081a04a07a40a0f5f6';
        const {
          witness: { signatures }
        } = await wallet.finalizeTx({ tx: cbor as any });
        expect(signatures.size).toBe(1);
      });

      it('throws if signed transaction hash doesnt match hash computed by the wallet', async () => {
        const originalHashFn = Serialization.TransactionBody.prototype.hash;
        jest
          .spyOn(Serialization.TransactionBody.prototype, 'hash')
          .mockReturnValue('non-matching' as unknown as Cardano.TransactionId);

        const txBody = Serialization.TransactionBody.fromCore(txInternals.body);
        await expect(
          ledgerKeyAgent.signTransaction(txBody, {
            knownAddresses: await firstValueFrom(wallet.addresses$),
            txInKeyPathMap: {}
          })
        ).rejects.toThrow();
        expect(Serialization.TransactionBody.prototype.hash).toHaveBeenCalled();

        Serialization.TransactionBody.prototype.hash = originalHashFn;
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
          data: Serialization.PlutusData.fromCbor(HexBlob('d8799fff')).toCore(),
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
          redeemersByType: {
            mint: [scriptRedeemer]
          },
          scriptIntegrityHash: scriptDataHash,
          witness: { redeemers: [scriptRedeemer], scripts: [script] }
        };

        const unsignedTx = await wallet.initializeTx(txProps);

        const {
          witness: { signatures }
        } = await wallet.finalizeTx({ tx: unsignedTx });
        expect(signatures.size).toBe(2);
      });

      it('can sign multi-delegation transaction', async () => {
        const txBuilder = wallet.createTxBuilder();
        const builtTx = await txBuilder
          .delegatePortfolio({
            name: 'Ledger multi-delegation Portfolio',
            pools: [
              {
                id: poolId1Hex,
                weight: 1
              },
              {
                id: poolId2Hex,
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

      describe('Native Scripts', () => {
        it('can sign transaction with native script - Payment credential', async () => {
          const selector = new LargeFirstSelector({
            changeAddressResolver: new MockChangeAddressResolver()
          });
          wallet.setInputSelector(selector);
          const txBuilder = wallet.createTxBuilder();
          const firstAddress = (await firstValueFrom(wallet.addresses$))[0].address;

          const builtTx = await txBuilder
            .addInput(
              [
                {
                  address: Cardano.PaymentAddress('addr_test1vzztre5epvtj5p72sh28nvrs3e6s4xxn95f66cvg0sqsk7qd3mah0'),
                  index: 0,
                  txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
                },
                outputs[0]
              ],
              {
                script: getPayToPubKeyHashScript(
                  getPaymentCredential(firstAddress).hash as unknown as Crypto.Ed25519KeyHashHex
                )
              }
            )
            .addOutput(txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(5_111_111n)).toTxOut())
            .customize(({ txBody }) => ({
              ...txBody,
              withdrawals: []
            }))
            .build()
            .inspect();

          const {
            witness: { signatures }
          } = await wallet.finalizeTx({ tx: builtTx, witness: builtTx.witness });

          expect(signatures.size).toBe(1);
        });

        it('can sign transaction with native script - Stake credential', async () => {
          const selector = new LargeFirstSelector({
            changeAddressResolver: new MockChangeAddressResolver()
          });
          wallet.setInputSelector(selector);
          const txBuilder = wallet.createTxBuilder();

          const builtTx = await txBuilder
            .addInput(
              [
                {
                  address: Cardano.PaymentAddress('addr_test1vzztre5epvtj5p72sh28nvrs3e6s4xxn95f66cvg0sqsk7qd3mah0'),
                  index: 0,
                  txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
                },
                outputs[0]
              ],
              {
                script: getPayToPubKeyHashScript(
                  getStakeCredential((await firstValueFrom(wallet.delegation.rewardAccounts$))?.[0].address)
                    .hash as unknown as Crypto.Ed25519KeyHashHex
                )
              }
            )
            .addOutput(txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(5_111_111n)).toTxOut())
            .customize(({ txBody }) => ({
              ...txBody,
              withdrawals: []
            }))
            .build()
            .inspect();

          const {
            witness: { signatures }
          } = await wallet.finalizeTx({ tx: builtTx, witness: builtTx.witness });

          expect(signatures.size).toBe(1);
        });
      });

      describe('conway-era', () => {
        describe('ordinary tx mode', () => {
          let dRepPublicKey: Crypto.Ed25519PublicKeyHex | undefined;
          let dRepKeyHash: Crypto.Ed25519KeyHashHex;

          beforeEach(async () => {
            dRepPublicKey = await wallet.governance.getPubDRepKey();
            if (!dRepPublicKey) throw new Error('No dRep pub key');
            dRepKeyHash = (await Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash()).hex();
          });

          it('can sign a transaction with Registration certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.Registration,
                deposit: 5n,
                stakeCredential: getStakeCredential(
                  (await firstValueFrom(wallet.delegation.rewardAccounts$))?.[0].address
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('would throw while trying to sign a transaction with Registration certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.Registration,
                deposit: 5n,
                stakeCredential: getStakeCredential(
                  Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            await expect(tx.sign()).rejects.toThrow(
              InvalidDataReason.SIGN_MODE_ORDINARY__CERTIFICATE_STAKE_CREDENTIAL_ONLY_AS_PATH
            );
          });

          it('can sign a transaction with Unregistration certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.Unregistration,
                deposit: 5n,
                stakeCredential: getStakeCredential(
                  (await firstValueFrom(wallet.delegation.rewardAccounts$))?.[0].address
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('would throw while trying to sign a transaction with Unregistration certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.Unregistration,
                deposit: 5n,
                stakeCredential: getStakeCredential(
                  Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            await expect(tx.sign()).rejects.toThrow(
              InvalidDataReason.SIGN_MODE_ORDINARY__CERTIFICATE_STAKE_CREDENTIAL_ONLY_AS_PATH
            );
          });

          it('can sign a transaction with VoteDelegation certs with dRep of credential type', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.VoteDelegation,
                dRep: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.KeyHash
                },
                stakeCredential: getStakeCredential(
                  (await firstValueFrom(wallet.delegation.rewardAccounts$))?.[0].address
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('can sign a transaction with VoteDelegation certs with dRep of AlwaysAbstain type', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.VoteDelegation,
                dRep: { __typename: 'AlwaysAbstain' },
                stakeCredential: getStakeCredential(
                  (await firstValueFrom(wallet.delegation.rewardAccounts$))?.[0].address
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('can sign a transaction with VoteDelegation certs with dRep of AlwaysNoConfidence type', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.VoteDelegation,
                dRep: { __typename: 'AlwaysNoConfidence' },
                stakeCredential: getStakeCredential(
                  (await firstValueFrom(wallet.delegation.rewardAccounts$))?.[0].address
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('would throw while trying to sign a transaction with VoteDelegation certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.VoteDelegation,
                dRep: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.KeyHash
                },
                stakeCredential: getStakeCredential(
                  Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
                )
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            await expect(tx.sign()).rejects.toThrow(
              InvalidDataReason.SIGN_MODE_ORDINARY__CERTIFICATE_STAKE_CREDENTIAL_ONLY_AS_PATH
            );
          });

          it('can sign a transaction with RegisterDelegateRepresentative certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
                anchor: null,
                dRepCredential: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.KeyHash
                },
                deposit: 5n
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('would throw while trying to sign a transaction with RegisterDelegateRepresentative certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
                anchor: null,
                dRepCredential: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.ScriptHash
                },
                deposit: 5n
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            await expect(tx.sign()).rejects.toThrow(
              InvalidDataReason.SIGN_MODE_ORDINARY__CERTIFICATE_DREP_CREDENTIAL_ONLY_AS_PATH
            );
          });

          it('can sign a transaction with UnregisterDelegateRepresentative certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
                dRepCredential: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.KeyHash
                },
                deposit: 5n
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('would throw while trying to sign a transaction with UnregisterDelegateRepresentative certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
                dRepCredential: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.ScriptHash
                },
                deposit: 5n
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            await expect(tx.sign()).rejects.toThrow(
              InvalidDataReason.SIGN_MODE_ORDINARY__CERTIFICATE_DREP_CREDENTIAL_ONLY_AS_PATH
            );
          });

          it('can sign a transaction with UpdateDelegateRepresentative certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.UpdateDelegateRepresentative,
                anchor: null,
                dRepCredential: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.KeyHash
                }
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            expect(await tx.sign()).toBeTruthy();
          });

          it('would throw while trying to sign a transaction with UpdateDelegateRepresentative certs', async () => {
            const txBuilder = wallet.createTxBuilder();
            txBuilder.partialTxBody.certificates = [
              {
                __typename: Cardano.CertificateType.UpdateDelegateRepresentative,
                anchor: null,
                dRepCredential: {
                  hash: dRepKeyHash,
                  type: Cardano.CredentialType.ScriptHash
                }
              }
            ];
            const tx = txBuilder
              .addOutput(
                txBuilder.buildOutput().address(outputs[0].address).coin(BigInt(outputs[0].value.coins)).toTxOut()
              )
              .build();

            await expect(tx.sign()).rejects.toThrow(
              InvalidDataReason.SIGN_MODE_ORDINARY__CERTIFICATE_DREP_CREDENTIAL_ONLY_AS_PATH
            );
          });

          it('can sign a transaction with voting procedures, treasury and donation', async () => {
            const votingProcedure: Cardano.VotingProcedures[0] = {
              voter: {
                __typename: Cardano.VoterType.dRepKeyHash,
                credential: { hash: Crypto.Hash28ByteBase16(dRepKeyHash), type: Cardano.CredentialType.KeyHash }
              },
              votes: [
                {
                  actionId: {
                    actionIndex: 3,
                    id: Cardano.TransactionId('1000000000000000000000000000000000000000000000000000000000000000')
                  },
                  votingProcedure: {
                    anchor: {
                      dataHash: Crypto.Hash32ByteBase16(
                        '0000000000000000000000000000000000000000000000000000000000000000'
                      ),
                      url: 'https://www.someurl.io'
                    },
                    vote: 0
                  }
                }
              ]
            };

            const txBuilder = wallet.createTxBuilder();
            const builtTx = txBuilder
              .customize(({ txBody }) => {
                const votingProcedures: Cardano.TxBody['votingProcedures'] = [
                  ...(txBody.votingProcedures || []),
                  votingProcedure
                ];
                return {
                  ...txBody,
                  donation: 1000n,
                  treasuryValue: 2000n,
                  votingProcedures
                };
              })
              .build();
            const signedTx = await builtTx.sign();
            // Payment witness + staking witness for withdrawals + DRep witness for voting
            expect(signedTx.tx.witness.signatures.size).toBe(3);
          });

          describe('CIP-008 Messages', () => {
            it('can sign a long message', async () => {
              const message = HexBlob(
                Buffer.from(
                  'STAR 00000000000 to addr_test1qpj0zrza6l4caj9q4yfnvugcfum5rls7tkzvezzatp488tev0tc8arve599qvp6r28hsf6tm0cfdm3f70u58rjuycgtsrypwh5 ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
                  'ascii'
                ).toString('hex')
              );
              const signWith = (await firstValueFrom(wallet.addresses$))[0].address;
              const { coseSign1, publicKeyHex, signedData } = await signAndDecode(signWith as any, wallet, message);
              const signedDataBytes = HexBlob.fromBytes(signedData.to_bytes());
              const signatureBytes = HexBlob.fromBytes(coseSign1.signature()) as unknown as Crypto.Ed25519SignatureHex;
              const cryptoProvider = await Crypto.SodiumBip32Ed25519.create();

              testAddressHeader(signedData, signWith);

              expect(
                cryptoProvider.verify(
                  signatureBytes,
                  signedDataBytes,
                  publicKeyHex as unknown as Crypto.Ed25519PublicKeyHex
                )
              ).toBe(true);
            });

            it('can sign with reward account', async () => {
              const signWith = (await firstValueFrom(wallet.addresses$))[0].rewardAccount;
              const { coseSign1, publicKeyHex, signedData } = await signAndDecode(signWith, wallet);
              const signedDataBytes = HexBlob.fromBytes(signedData.to_bytes());
              const signatureBytes = HexBlob.fromBytes(coseSign1.signature()) as unknown as Crypto.Ed25519SignatureHex;
              const cryptoProvider = await Crypto.SodiumBip32Ed25519.create();

              testAddressHeader(signedData, signWith);

              expect(
                cryptoProvider.verify(
                  signatureBytes,
                  signedDataBytes,
                  publicKeyHex as unknown as Crypto.Ed25519PublicKeyHex
                )
              ).toBe(true);
            });

            it('can sign with base address', async () => {
              const signWith = (await firstValueFrom(wallet.addresses$))[0].address;
              const { coseSign1, publicKeyHex, signedData } = await signAndDecode(signWith, wallet);
              const signedDataBytes = HexBlob.fromBytes(signedData.to_bytes());
              const signatureBytes = HexBlob.fromBytes(coseSign1.signature()) as unknown as Crypto.Ed25519SignatureHex;
              const cryptoProvider = await Crypto.SodiumBip32Ed25519.create();

              testAddressHeader(signedData, signWith);

              expect(
                cryptoProvider.verify(
                  signatureBytes,
                  signedDataBytes,
                  publicKeyHex as unknown as Crypto.Ed25519PublicKeyHex
                )
              ).toBe(true);
            });

            it('can sign with drep key', async () => {
              const drepPubKey = await wallet.governance.getPubDRepKey();
              const signWith = (await buildDRepAddressFromDRepKey(drepPubKey!))?.toAddress()?.toBech32();
              const { coseSign1, publicKeyHex, signedData } = await signAndDecode(signWith!, wallet);
              const signedDataBytes = HexBlob.fromBytes(signedData.to_bytes());
              const signatureBytes = HexBlob.fromBytes(coseSign1.signature()) as unknown as Crypto.Ed25519SignatureHex;
              const cryptoProvider = await Crypto.SodiumBip32Ed25519.create();

              expect(publicKeyHex).toEqual(drepPubKey);

              expect(
                cryptoProvider.verify(
                  signatureBytes,
                  signedDataBytes,
                  publicKeyHex as unknown as Crypto.Ed25519PublicKeyHex
                )
              ).toBe(true);
            });
          });
        });
      });
    });

    describe('serializableData', () => {
      let serializableData: SerializableLedgerKeyAgentData;

      beforeEach(() => {
        serializableData = ledgerKeyAgent.serializableData as SerializableLedgerKeyAgentData;
      });

      it('all fields are of correct types', () => {
        expect(typeof serializableData.__typename).toBe('string');
        expect(typeof serializableData.accountIndex).toBe('number');
        expect(typeof serializableData.chainId).toBe('object');
        expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
        expect(typeof serializableData.communicationType).toBe('string');
      });

      it('is serializable', () => {
        expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
      });
    });
  });

  describe('deviceConnections persistence', () => {
    let createTransportSpy: jest.SpyInstance;
    beforeAll(async () => {
      createTransportSpy = jest.spyOn(LedgerKeyAgent, 'createTransport');
    });

    afterEach(async () => {
      await cleanupEstablishedConnections();
      createTransportSpy.mockClear();
    });

    it('should return an existing connection if one exists', async () => {
      const connection1 = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);
      const connection2 = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);

      expect(createTransportSpy).toHaveBeenCalledTimes(1);
      expect(connection1).toBe(connection2);
    });

    it('should return an existing connection if one exists when passing a device object', async () => {
      const hidDevice = getHidDevice();
      const connection1 = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node, hidDevice);
      const connection2 = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node, hidDevice);

      expect(connection1).toBe(connection2);
      await connection2.transport.close();
      hidDevice.close();
    });

    it('should create a new connection if none match the requested parameters', async () => {
      LedgerKeyAgent.deviceConnections = [
        {
          communicationType: CommunicationType.Web,
          deviceConnection: { transport: { close: () => void 0 } } as any
        }
      ];
      const connection = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);

      expect(createTransportSpy).toHaveBeenCalledTimes(1);
      expect(LedgerKeyAgent.deviceConnections).toHaveLength(2);
      expect(LedgerKeyAgent.deviceConnections[1].deviceConnection).toBe(connection);
    });

    it('removes connection matching the requested parameters if it is broken', async () => {
      const rememberedConnection = {
        communicationType: CommunicationType.Node,
        deviceConnection: { transport: { close: () => void 0 } } as any
      };
      LedgerKeyAgent.deviceConnections = [rememberedConnection];
      const deviceConnection = await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);

      expect(LedgerKeyAgent.deviceConnections).toHaveLength(1);
      expect(LedgerKeyAgent.deviceConnections[0]).not.toBe(rememberedConnection);
      expect(LedgerKeyAgent.deviceConnections[0].deviceConnection).toBe(deviceConnection);
    });

    it('should create a new connection if none are available', async () => {
      await LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);
      expect(createTransportSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('establish, check and re-establish device connection', () => {
    let deviceConnection: DeviceConnection;
    beforeAll(async () => {
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
});
