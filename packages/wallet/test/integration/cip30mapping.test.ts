/* eslint-disable @typescript-eslint/no-explicit-any, sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import * as mocks from '../mocks';
import {
  APIErrorCode,
  ApiError,
  DataSignError,
  DataSignErrorCode,
  TxSendError,
  TxSignError,
  WalletApi
} from '@cardano-sdk/dapp-connector';
import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { CML, Cardano, CardanoNodeErrors, TxCBOR, cmlToCore, coreToCml } from '@cardano-sdk/core';
import { HexBlob, ManagedFreeableScope } from '@cardano-sdk/util';
import { InMemoryUnspendableUtxoStore, createInMemoryWalletStores } from '../../src/persistence';
import { InitializeTxProps, InitializeTxResult, SingleAddressWallet, cip30, setupWallet } from '../../src';
import { Providers, createWallet } from './util';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom, of } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import {
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  utxo as mockUtxo,
  utxo as mockedUtxo,
  utxosWithLowCoins
} from '../mocks';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { waitForWalletStateSettle } from '../util';

type TestProviders = Required<Pick<Providers, 'txSubmitProvider' | 'networkInfoProvider'>>;

const createWalletAndApiWithStores = async (utxos: Cardano.Utxo[], providers?: TestProviders, settle = true) => {
  const unspendableUtxo = new InMemoryUnspendableUtxoStore();
  unspendableUtxo.setAll(utxos);
  const stores = { ...createInMemoryWalletStores(), unspendableUtxo };
  const { wallet } = await createWallet(stores, providers);
  const confirmationCallback = jest.fn().mockResolvedValue(true);
  const api = cip30.createWalletApi(of(wallet), confirmationCallback, { logger });
  if (settle) await waitForWalletStateSettle(wallet);
  return { api, confirmationCallback, wallet };
};

describe('cip30', () => {
  let wallet: SingleAddressWallet;
  let api: WalletApi;
  let confirmationCallback: jest.Mock;

  const simpleTxProps: InitializeTxProps = {
    outputs: new Set([
      {
        address: Cardano.PaymentAddress(
          // eslint-disable-next-line max-len
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 1_111_111n }
      }
    ])
  };

  describe('with custom ledgerTip', () => {
    let providers: TestProviders;
    let resolveTip: (tip: Cardano.Tip) => void;

    beforeEach(async () => {
      providers = {
        networkInfoProvider: mockNetworkInfoProvider(),
        txSubmitProvider: mockTxSubmitProvider()
      };
      providers.networkInfoProvider.ledgerTip.mockImplementation(
        () =>
          new Promise((resolve) => {
            resolveTip = resolve;
          })
      );
      // CREATE A WALLET
      ({ wallet, api, confirmationCallback } = await createWalletAndApiWithStores([mockedUtxo[2]], providers, false));
    });

    afterEach(() => {
      wallet.shutdown();
    });

    describe('createWalletApi', () => {
      describe('api.submitTx', () => {
        it('can submit a transaction that is not consistently reserialized with CML', async () => {
          const serializedTx = TxCBOR(
            // eslint-disable-next-line max-len
            '84a60081825820260aed6e7a24044b1254a87a509468a649f522a4e54e830ac10f27ea7b5ec61f01018383581d70b429738bd6cc58b5c7932d001aa2bd05cfea47020a556c8c753d44361a004c4b40582007845f8f3841996e3d8157954e2f5e2fb90465f27112fc5fe9056d916fae245b82583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba1a0463676982583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba821a00177a6ea2581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff198a5447742544319271044774554481a0031f9194577444f47451a0056898d4577555344431a000fc589467753484942411a000103c2581c659ab0b5658687c2e74cd10dba8244015b713bf503b90557769d77a7a14a57696e675269646572731a02269552021a0002e665031a01353f84081a013531740b58204107eada931c72a600a6e3305bd22c7aeb9ada7c3f6823b155f4db85de36a69aa20081825820e686ade5bc97372f271fd2abc06cfd96c24b3d9170f9459de1d8e3dd8fd385575840653324a9dddad004f05a8ac99fa2d1811af5f00543591407fb5206cfe9ac91bb1412404323fa517e0e189684cd3592e7f74862e3f16afbc262519abec958180c0481d8799fd8799fd8799fd8799f581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68ffd8799fd8799fd8799f581c042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339baffffffff581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c681b000001863784a12ed8799fd8799f4040ffd8799f581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff1984577444f4745ffffffd8799fd87980190c8efffff5f6'
          );
          resolveTip({
            blockNo: Cardano.BlockNo(123),
            hash: Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000'),
            // Validity interval of serializedTx is 20263284 <= n <= 20266884
            slot: Cardano.Slot(20_263_285)
          });
          await expect(api.submitTx(serializedTx)).resolves.not.toThrow();
          expect(providers.txSubmitProvider.submitTx).toHaveBeenCalledWith({ signedTransaction: serializedTx });
        });
      });
    });
  });

  describe('with default mock data', () => {
    let scope: ManagedFreeableScope;
    let providers: TestProviders;

    beforeAll(async () => {
      // CREATE A WALLET
      scope = new ManagedFreeableScope();
      providers = {
        networkInfoProvider: mockNetworkInfoProvider(),
        txSubmitProvider: mockTxSubmitProvider()
      };
      ({ wallet, api, confirmationCallback } = await createWalletAndApiWithStores([mockedUtxo[4]], providers));
    });

    afterAll(() => {
      wallet.shutdown();
      scope.dispose();
    });

    describe('createWalletApi', () => {
      test('api.getNetworkId', async () => {
        const cip30NetworkId = await api.getNetworkId();
        expect(cip30NetworkId).toEqual(Cardano.NetworkId.Testnet);
      });

      test('api.getUtxos', async () => {
        const utxos = await api.getUtxos();
        expect(() =>
          cmlToCore.utxo(
            utxos!.map((utxo) => scope.manage(CML.TransactionUnspentOutput.from_bytes(Buffer.from(utxo, 'hex'))))
          )
        ).not.toThrow();
      });

      describe('api.getCollateral', () => {
        // Wallet 2
        let wallet2: SingleAddressWallet;
        let api2: WalletApi;

        // Wallet 3
        let wallet3: SingleAddressWallet;
        let api3: WalletApi;

        // Wallet 4
        let wallet4: SingleAddressWallet;
        let api4: WalletApi;

        beforeAll(async () => {
          // CREATE A WALLET WITH LOW COINS UTXOS
          ({ wallet: wallet2, api: api2 } = await createWalletAndApiWithStores(utxosWithLowCoins));

          // CREATE A WALLET WITH NO UTXOS
          ({ wallet: wallet3, api: api3 } = await createWalletAndApiWithStores([]));

          // CREATE A WALLET WITH UTXOS WITH ASSETS
          ({ wallet: wallet4, api: api4 } = await createWalletAndApiWithStores([mockedUtxo[1], mockedUtxo[2]]));
        });

        afterAll(() => {
          wallet2.shutdown();
          wallet3.shutdown();
          wallet4.shutdown();
        });

        test('can handle an unknown error', async () => {
          // YYYY is invalid hex that will throw at serialization
          await expect(api.getCollateral({ amount: 'YYYY' })).rejects.toThrowError(
            expect.objectContaining({ code: APIErrorCode.InternalError, info: 'Unknown error' })
          );
        });

        test('returns multiple UTxOs when more than 1 utxo needed to satisfy amount', async () => {
          // 1a003d0900 Represents a CML.BigNum object of 4 ADA
          const utxos = await api2.getCollateral({ amount: '1a003d0900' });
          // eslint-disable-next-line sonarjs/no-identical-functions
          expect(() =>
            cmlToCore.utxo(
              utxos!.map((utxo) => scope.manage(CML.TransactionUnspentOutput.from_bytes(Buffer.from(utxo, 'hex'))))
            )
          ).not.toThrow();
          expect(utxos).toHaveLength(2);
        });

        test('throws when there are not enough UTxOs', async () => {
          // 1a004c4b40 Represents a CML.BigNum object of 5 ADA
          await expect(api2.getCollateral({ amount: '1a004c4b40' })).rejects.toThrow(ApiError);
        });

        test('returns null when there are no "unspendable" UTxOs in the wallet', async () => {
          // 1a003d0900 Represents a CML.BigNum object of 4 ADA
          expect(await api3.getCollateral({ amount: '1a003d0900' })).toBe(null);
          wallet3.shutdown();
        });

        test('throws when the given amount is greater than max amount', async () => {
          // 1a005b8d80 Represents a CML.BigNum object of 6 ADA
          await expect(api2.getCollateral({ amount: '1a005b8d80' })).rejects.toThrow(ApiError);
        });

        test('returns first UTxO when amount is 0', async () => {
          // 00 Represents a CML.BigNum object of 0 ADA
          const utxos = await api2.getCollateral({ amount: '00' });
          // eslint-disable-next-line sonarjs/no-identical-functions
          expect(() =>
            cmlToCore.utxo(
              utxos!.map((utxo) => scope.manage(CML.TransactionUnspentOutput.from_bytes(Buffer.from(utxo, 'hex'))))
            )
          ).not.toThrow();
        });

        test('returns all UTxOs when there is no given amount', async () => {
          const utxos = await api.getCollateral();
          // eslint-disable-next-line sonarjs/no-identical-functions
          expect(() =>
            cmlToCore.utxo(
              utxos!.map((utxo) => scope.manage(CML.TransactionUnspentOutput.from_bytes(Buffer.from(utxo, 'hex'))))
            )
          ).not.toThrow();
          expect(utxos).toHaveLength(1);
        });

        test('returns null when there is no given amount and wallet has no UTxOs', async () => {
          expect(await api3.getCollateral()).toBe(null);
        });

        test('throws when unspendable UTxOs contain assets', async () => {
          await expect(api4.getCollateral()).rejects.toThrow(ApiError);
        });
      });

      test('api.getBalance', async () => {
        const balanceCborBytes = Buffer.from(await api.getBalance(), 'hex');
        expect(() => scope.manage(CML.Value.from_bytes(balanceCborBytes))).not.toThrow();
      });

      test('api.getUsedAddresses', async () => {
        const cipUsedAddressess = await api.getUsedAddresses();
        const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
        expect(cipUsedAddressess.map((cipAddr) => Cardano.PaymentAddress(cipAddr))).toEqual([walletAddress]);
      });

      test('api.getUnusedAddresses', async () => {
        const cipUsedAddressess = await api.getUnusedAddresses();
        expect(cipUsedAddressess).toEqual([]);
      });

      test('api.getChangeAddress', async () => {
        const cipChangeAddress = await api.getChangeAddress();
        const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
        expect(Cardano.PaymentAddress(cipChangeAddress)).toEqual(walletAddress);
      });

      test('api.getRewardAddresses', async () => {
        const cipRewardAddressesCbor = await api.getRewardAddresses();
        const cipRewardAddresses = cipRewardAddressesCbor.map((cipAddr) =>
          Cardano.Address.fromBytes(HexBlob(cipAddr)).toBech32()
        );

        const [{ rewardAccount: walletRewardAccount }] = await firstValueFrom(wallet.addresses$);
        expect(cipRewardAddresses).toEqual([walletRewardAccount]);
      });

      test('api.signTx', async () => {
        const txInternals = await wallet.initializeTx(simpleTxProps);
        const finalizedTx = await wallet.finalizeTx({ tx: txInternals });
        const hexTx = Buffer.from(coreToCml.tx(scope, finalizedTx).to_bytes()).toString('hex');

        const cip30witnessSet = await api.signTx(hexTx);
        const signatures = Buffer.from(cip30witnessSet, 'hex');
        expect(() => scope.manage(CML.TransactionWitnessSet.from_bytes(signatures))).not.toThrow();
      });

      test('api.signData', async () => {
        const [{ address }] = await firstValueFrom(wallet.addresses$);
        const cip30dataSignature = await api.signData(address, HexBlob('abc123'));
        expect(typeof cip30dataSignature.key).toBe('string');
        expect(typeof cip30dataSignature.signature).toBe('string');
      });

      describe('api.submitTx', () => {
        let finalizedTx: Cardano.Tx;
        let txBytes: Uint8Array;
        let hexTx: string;

        beforeEach(async () => {
          const txInternals = await wallet.initializeTx(simpleTxProps);
          finalizedTx = await wallet.finalizeTx({ tx: txInternals });
          txBytes = coreToCml.tx(scope, finalizedTx).to_bytes();
          hexTx = Buffer.from(txBytes).toString('hex');
        });

        it('resolves with transaction id when submitting a valid transaction', async () => {
          const txId = await api.submitTx(hexTx);
          expect(txId).toBe(finalizedTx.id);
        });

        // Need to find a transaction that body can't be consistently re-serialized by using our serialization utils
        it.todo('resolves with original transactionId (not the one computed when re-serializing the transaction)');

        it('throws ApiError when submitting a transaction that has invalid encoding', async () => {
          await expect(api.submitTx(Buffer.from(txBytes).toString('base64'))).rejects.toThrowError(ApiError);
        });

        it('throws ApiError when submitting a hex string that is not a serialized transaction', async () => {
          await expect(api.submitTx(Buffer.from([0, 1, 3]).toString('hex'))).rejects.toThrowError(ApiError);
        });

        it('throws TxSendError when submission fails', async () => {
          providers.txSubmitProvider.submitTx.mockRejectedValueOnce(
            new CardanoNodeErrors.TxSubmissionErrors.OutsideOfValidityIntervalError({
              outsideOfValidityInterval: { currentSlot: 5, interval: { invalidBefore: 6, invalidHereafter: 7 } }
            })
          );
          await expect(api.submitTx(hexTx)).rejects.toThrowError(TxSendError);
        });
      });
    });

    describe('confirmation callbacks', () => {
      describe('signData', () => {
        const payload = 'abc123';

        test('resolves true', async () => {
          confirmationCallback.mockResolvedValueOnce(true);
          await expect(api.signData(wallet.addresses$.value![0].address, payload)).resolves.not.toThrow();
        });

        test('resolves false', async () => {
          confirmationCallback.mockResolvedValueOnce(false);
          await expect(api.signData(wallet.addresses$.value![0].address, payload)).rejects.toThrowError(DataSignError);
        });

        test('rejects', async () => {
          confirmationCallback.mockRejectedValue(1);
          await expect(api.signData(wallet.addresses$.value![0].address, payload)).rejects.toThrowError(DataSignError);
        });

        test('gets the Cardano.Address equivalent of the hex address', async () => {
          confirmationCallback.mockClear();
          confirmationCallback.mockResolvedValueOnce(true);

          const expectedAddr = wallet.addresses$.value![0].address;
          const hexAddr = Cardano.Address.fromBech32(expectedAddr).toBytes();

          await api.signData(hexAddr, payload);
          expect(confirmationCallback).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ addr: expectedAddr }) })
          );
        });
      });

      describe('signTx', () => {
        let hexTx: string;
        beforeAll(async () => {
          const txInternals = await wallet.initializeTx(simpleTxProps);
          const finalizedTx = await wallet.finalizeTx({ tx: txInternals });
          hexTx = Buffer.from(coreToCml.tx(scope, finalizedTx).to_bytes()).toString('hex');
        });

        test('resolves true', async () => {
          confirmationCallback.mockResolvedValueOnce(true);
          await expect(api.signTx(hexTx)).resolves.not.toThrow();
        });

        test('resolves false', async () => {
          confirmationCallback.mockResolvedValueOnce(false);
          await expect(api.signTx(hexTx)).rejects.toThrowError(TxSignError);
        });

        test('rejects', async () => {
          confirmationCallback.mockRejectedValue(1);
          await expect(api.signTx(hexTx)).rejects.toThrowError(TxSignError);
        });
      });

      describe('submitTx', () => {
        let cmlTx: string;
        let txInternals: InitializeTxResult;
        let finalizedTx: Cardano.Tx<Cardano.TxBody>;

        beforeAll(async () => {
          txInternals = await wallet.initializeTx(simpleTxProps);
          finalizedTx = await wallet.finalizeTx({ tx: txInternals });

          cmlTx = Buffer.from(coreToCml.tx(scope, finalizedTx).to_bytes()).toString('hex');
        });

        test('resolves true', async () => {
          confirmationCallback.mockResolvedValueOnce(true);
          await expect(api.submitTx(cmlTx)).resolves.toBe(finalizedTx.id);
        });

        test('resolves false', async () => {
          confirmationCallback.mockResolvedValueOnce(false);
          await expect(api.submitTx(cmlTx)).rejects.toThrowError(TxSendError);
        });

        test('rejects', async () => {
          confirmationCallback.mockRejectedValue(1);
          await expect(api.submitTx(cmlTx)).rejects.toThrowError(TxSendError);
        });
      });
    });

    describe('ProofGeneration errors', () => {
      const address = mocks.utxo[0][0].address!;
      let txSubmitProvider: mocks.TxSubmitProviderStub;
      let networkInfoProvider: mocks.NetworkInfoProviderStub;
      let mockWallet: SingleAddressWallet;
      let utxoProvider: mocks.UtxoProviderStub;
      let tx: Cardano.Tx;
      let mockApi: WalletApi;

      beforeEach(async () => {
        txSubmitProvider = mocks.mockTxSubmitProvider();
        networkInfoProvider = mocks.mockNetworkInfoProvider();
        utxoProvider = mocks.mockUtxoProvider();
        const assetProvider = mocks.mockAssetProvider();
        const stakePoolProvider = createStubStakePoolProvider();
        const rewardsProvider = mockRewardsProvider();
        const chainHistoryProvider = mockChainHistoryProvider();
        const groupedAddress: GroupedAddress = {
          accountIndex: 0,
          address,
          index: 0,
          networkId: Cardano.NetworkId.Testnet,
          rewardAccount: mocks.rewardAccount,
          stakeKeyDerivationPath: mocks.stakeKeyDerivationPath,
          type: AddressType.External
        };
        ({ wallet: mockWallet } = await setupWallet({
          bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
          createKeyAgent: async (dependencies) => {
            const asyncKeyAgent = await testAsyncKeyAgent([groupedAddress], dependencies);
            asyncKeyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
            return asyncKeyAgent;
          },
          createWallet: async (keyAgent) =>
            new SingleAddressWallet(
              { name: 'Test Wallet' },
              {
                assetProvider,
                chainHistoryProvider,
                keyAgent,
                logger,
                networkInfoProvider,
                rewardsProvider,
                stakePoolProvider,
                txSubmitProvider,
                utxoProvider
              }
            ),
          logger
        }));

        await waitForWalletStateSettle(mockWallet);
        mockApi = cip30.createWalletApi(of(mockWallet), jest.fn().mockResolvedValue(true), { logger });

        const props = {
          certificates: [
            {
              __typename: Cardano.CertificateType.StakeKeyDeregistration,
              stakeKeyHash: mocks.stakeKeyHash
            } as Cardano.StakeAddressCertificate
          ],
          collaterals: new Set([mockUtxo[2][0]]),
          outputs: new Set([
            {
              address: Cardano.PaymentAddress(
                // eslint-disable-next-line max-len
                'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
              ),
              value: { coins: 11_111_111n }
            }
          ])
        };

        tx = await mockWallet.finalizeTx({ tx: await mockWallet.initializeTx(props) });
      });

      afterEach(() => {
        mockWallet.shutdown();
      });

      it(
        'dont throw DataSignError with ProofGeneration as error code if all inputs/certs can be signed and ' +
          ' partialSign is set to false',
        async () => {
          const cbor = TxCBOR.serialize(tx);

          // Inputs are selected by input selection algorithm
          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(1);
          await expect(mockApi.signTx(cbor, false)).resolves.not.toThrow();
        }
      );

      it(
        'dont throw DataSignError with ProofGeneration as error code if all inputs/certs can be signed and ' +
          ' partialSign is set to true',
        async () => {
          const cbor = TxCBOR.serialize(tx);

          tx.witness = {
            signatures: new Map([
              [
                Crypto.Ed25519PublicKeyHex('0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'),
                Crypto.Ed25519SignatureHex(
                  // eslint-disable-next-line max-len
                  '0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c40b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'
                )
              ]
            ])
          };

          mockWallet.finalizeTx = () => Promise.resolve(tx as unknown as Cardano.Tx);

          // Inputs are selected by input selection algorithm
          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(1);
          await expect(mockApi.signTx(cbor, true)).resolves.not.toThrow();
        }
      );

      it(
        'dont throw DataSignError with ProofGeneration as error code if at least one input can be signed and ' +
          ' partialSign is set to true',
        async () => {
          const cbor = TxCBOR.serialize(tx);

          tx.witness = {
            signatures: new Map([
              [
                Crypto.Ed25519PublicKeyHex('0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'),
                Crypto.Ed25519SignatureHex(
                  // eslint-disable-next-line max-len
                  '0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c40b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'
                )
              ]
            ])
          };

          tx.body.inputs = [
            {
              index: 0,
              txId: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
            },
            ...tx.body.inputs
          ];

          mockWallet.finalizeTx = () => Promise.resolve(tx as unknown as Cardano.Tx);

          // Inputs are selected by input selection algorithm
          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(1);
          await expect(mockApi.signTx(cbor, true)).resolves.not.toThrow();
        }
      );

      it(
        'dont throw DataSignError with ProofGeneration as error code if at least one cert can be signed and ' +
          ' partialSign is set to true',
        async () => {
          const foreignRewardAccountHash = Cardano.RewardAccount.toHash(
            Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
          );

          const cbor = TxCBOR.serialize(tx);

          tx.witness = {
            signatures: new Map([
              [
                Crypto.Ed25519PublicKeyHex('0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'),
                Crypto.Ed25519SignatureHex(
                  // eslint-disable-next-line max-len
                  '0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c40b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'
                )
              ]
            ])
          };

          tx.body.certificates = [
            {
              __typename: Cardano.CertificateType.StakeDelegation,
              poolId: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash),
              stakeKeyHash: foreignRewardAccountHash
            } as Cardano.StakeDelegationCertificate,
            ...tx.body.certificates!
          ];

          mockWallet.finalizeTx = () => Promise.resolve(tx as unknown as Cardano.Tx);

          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(2);
          await expect(mockApi.signTx(cbor, true)).resolves.not.toThrow();
        }
      );

      it(
        'throw DataSignError with ProofGeneration as error code if the wallet cant sign a single input/cert and ' +
          ' partialSign is set to true',
        async () => {
          const cbor = TxCBOR.serialize(tx);

          tx.witness = { signatures: new Map() };
          mockWallet.finalizeTx = () => Promise.resolve(tx as unknown as Cardano.Tx);

          // Inputs are selected by input selection algorithm
          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(1);

          await expect(mockApi.signTx(cbor, true)).rejects.toMatchObject(
            new DataSignError(
              DataSignErrorCode.ProofGeneration,
              'The wallet does not have the secret key associated with any of the inputs and certificates.'
            )
          );
        }
      );

      it(
        'throw DataSignError with ProofGeneration as error code if at least one input can not be signed and ' +
          ' partialSign is set to false',
        async () => {
          tx.body.inputs = [
            {
              index: 0,
              txId: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
            },
            ...tx.body.inputs
          ];

          const cbor = TxCBOR.serialize(tx);

          // Inputs are selected by input selection algorithm
          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(1);

          await expect(mockApi.signTx(cbor, false)).rejects.toMatchObject(
            new DataSignError(
              DataSignErrorCode.ProofGeneration,
              'The wallet does not have the secret key associated with some of the inputs or certificates.'
            )
          );
        }
      );

      it(
        'throw DataSignError with ProofGeneration as error code if at least one cert can not be signed and ' +
          ' partialSign is set to false',
        async () => {
          const foreignRewardAccountHash = Cardano.RewardAccount.toHash(
            Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
          );

          tx.body.certificates = [
            {
              __typename: Cardano.CertificateType.StakeDelegation,
              poolId: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash),
              stakeKeyHash: foreignRewardAccountHash
            } as Cardano.StakeDelegationCertificate,
            ...tx.body.certificates!
          ];

          const cbor = TxCBOR.serialize(tx);

          // Inputs are selected by input selection algorithm
          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(2);

          await expect(mockApi.signTx(cbor, false)).rejects.toMatchObject(
            new DataSignError(
              DataSignErrorCode.ProofGeneration,
              'The wallet does not have the secret key associated with some of the inputs or certificates.'
            )
          );
        }
      );
    });
  });
});
