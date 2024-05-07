/* eslint-disable unicorn/consistent-destructuring */
/* eslint-disable unicorn/consistent-function-scoping */
/* eslint-disable @typescript-eslint/no-explicit-any, sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import {
  APIErrorCode,
  ApiError,
  DataSignError,
  DataSignErrorCode,
  Paginate,
  SenderContext,
  TxSendError,
  TxSignError,
  WalletApi,
  WithSenderContext
} from '@cardano-sdk/dapp-connector';
import { AddressType, Bip32Account, GroupedAddress, util } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { BaseWallet, cip30, createPersonalWallet } from '../../src';
import { CallbackConfirmation, GetCollateralCallbackParams } from '../../src/cip30';
import {
  Cardano,
  OutsideOfValidityIntervalData,
  Serialization,
  TxCBOR,
  TxSubmissionError,
  TxSubmissionErrorCode,
  coalesceValueQuantities
} from '@cardano-sdk/core';
import { HexBlob, ManagedFreeableScope } from '@cardano-sdk/util';
import { InMemoryUnspendableUtxoStore, createInMemoryWalletStores } from '../../src/persistence';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { Providers, createWallet } from './util';
import { buildDRepIDFromDRepKey, signTx, waitForWalletStateSettle } from '../util';
import { firstValueFrom, of } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { stakeKeyDerivationPath, testAsyncKeyAgent } from '../../../key-management/test/mocks';
import uniq from 'lodash/uniq';

const {
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  utxo: mockUtxo,
  utxosWithLowCoins,
  utxosWithLowCoinsAndMixedAssets,
  sortedUtxosWithLowCoins
} = mocks;

type TestProviders = Required<Pick<Providers, 'txSubmitProvider' | 'networkInfoProvider'>>;
const mockCollateralCallback = jest.fn().mockResolvedValue([mockUtxo[3]]);
const createMockGenericCallback = () => jest.fn().mockResolvedValue(true);

const createWalletAndApiWithStores = async (
  unspendableUtxos: Cardano.Utxo[],
  providers?: TestProviders,
  getCollateralCallback?: (args: GetCollateralCallbackParams) => Promise<Cardano.Utxo[]>,
  settle = true,
  availableUtxos?: Cardano.Utxo[]
) => {
  const unspendableUtxo = new InMemoryUnspendableUtxoStore();
  unspendableUtxo.setAll(unspendableUtxos);

  const stores = {
    ...createInMemoryWalletStores(),
    unspendableUtxo
  };
  const { wallet } = await createWallet(stores, providers);
  if (availableUtxos) {
    wallet.utxo.available$ = of(availableUtxos);
  }
  const confirmationCallback = {
    signData: createMockGenericCallback(),
    signTx: createMockGenericCallback(),
    submitTx: createMockGenericCallback(),
    ...(!!getCollateralCallback && { getCollateral: getCollateralCallback })
  };
  wallet.governance.getPubDRepKey = jest.fn(wallet.governance.getPubDRepKey);

  const api = cip30.createWalletApi(of(wallet), confirmationCallback, { logger });
  if (settle) await waitForWalletStateSettle(wallet);
  return { api, confirmationCallback, wallet };
};

describe('cip30', () => {
  const context: SenderContext = { sender: { url: 'https://lace.io' } };
  let wallet: BaseWallet;
  let api: WithSenderContext<WalletApi>;
  let confirmationCallback: CallbackConfirmation;

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
      ({ wallet, api, confirmationCallback } = await createWalletAndApiWithStores(
        [mockUtxo[2]],
        providers,
        undefined,
        false
      ));
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
          await expect(api.submitTx(context, serializedTx)).resolves.not.toThrow();
          expect(providers.txSubmitProvider.submitTx).toHaveBeenCalledWith({ signedTransaction: serializedTx });
        });
      });
    });
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
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
      ({ wallet, api, confirmationCallback } = await createWalletAndApiWithStores([mockUtxo[4]], providers));
    });

    afterAll(() => {
      wallet.shutdown();
      scope.dispose();
    });

    describe('createWalletApi', () => {
      test('api.getNetworkId', async () => {
        const cip30NetworkId = await api.getNetworkId(context);
        expect(cip30NetworkId).toEqual(Cardano.NetworkId.Testnet);
      });

      describe('api.getUtxos', () => {
        it('returns all utxo without arguments', async () => {
          const utxos = await api.getUtxos(context);
          expect(utxos?.length).toBe((await firstValueFrom(wallet.utxo.available$)).length);
          expect(() =>
            utxos!.map((utxo) => Serialization.TransactionUnspentOutput.fromCbor(HexBlob(utxo)))
          ).not.toThrow();
        });

        describe('with "amount" argument', () => {
          const getUtxoFiltered = async (coins: Cardano.Lovelace, tslaQuantity?: bigint, paginate?: Paginate) => {
            const filterAmountValue = new Serialization.Value(coins);
            if (tslaQuantity) {
              const multiAsset = new Map();
              multiAsset.set(AssetId.TSLA, tslaQuantity);
              multiAsset.set(AssetId.TSLA, tslaQuantity);
              filterAmountValue.setMultiasset(multiAsset);
            }
            const utxoCbor = await api.getUtxos(context, filterAmountValue.toCbor(), paginate);
            if (!utxoCbor) return null;
            return utxoCbor.map((utxo) => Serialization.TransactionUnspentOutput.fromCbor(HexBlob(utxo)).toCore());
          };

          it('returns just enough utxo to cover the amount', async () => {
            const minCoinsAmount = 1000n;
            const minTokensAmount = 20n;
            const utxo = await getUtxoFiltered(minCoinsAmount, minTokensAmount);
            expect(utxo?.length).toBeLessThan((await firstValueFrom(wallet.utxo.available$)).length);
            const totalQuantities = coalesceValueQuantities(utxo!.map(([_, txOut]) => txOut.value));
            expect(totalQuantities.coins).toBeGreaterThan(minCoinsAmount);
            expect(totalQuantities.assets?.get(AssetId.TSLA)).toBeGreaterThan(minTokensAmount);
          });

          it('returns null when it has insufficient coins balance to cover the requested amount', async () => {
            expect(await getUtxoFiltered(99_999_999_999_999_999n)).toBeNull();
          });

          it('returns null when it has insufficient tokens balance to cover the requested amount', async () => {
            expect(await getUtxoFiltered(1n, 99_999_999_999_999_999n)).toBeNull();
          });

          describe('with "paginate" argument', () => {
            it('when requested coins amount can be resolved, returns utxo in pages', async () => {
              const requestedCoins = 4_033_605_597n;
              const pageSize = 1;
              let page = 0;
              const utxo: (readonly [Cardano.TxIn, Cardano.TxOut])[] = [];
              do {
                const utxoChunk = await getUtxoFiltered(requestedCoins, 1n, { limit: pageSize, page: page++ });
                expect(utxoChunk).toHaveLength(pageSize);
                if (!utxoChunk) {
                  throw new Error('Not enough utxo');
                }
                utxo.push(...utxoChunk);
              } while (coalesceValueQuantities(utxo.map(([_, { value }]) => value)).coins < requestedCoins);
              // pagination had more than 1 page
              expect(utxo.length).toBeGreaterThan(pageSize);
            });

            it('when requested tokens amount can be resolved, returns utxo in pages', async () => {
              const requestedTokens = 20n;
              const pageSize = 1;
              let page = 0;
              const utxo: (readonly [Cardano.TxIn, Cardano.TxOut])[] = [];
              do {
                const utxoChunk = await getUtxoFiltered(1n, requestedTokens, { limit: pageSize, page: page++ });
                expect(utxoChunk).toHaveLength(pageSize);
                if (!utxoChunk) {
                  throw new Error('Not enough utxo');
                }
                utxo.push(...utxoChunk);
              } while (
                (coalesceValueQuantities(utxo.map(([_, { value }]) => value)).assets?.get(AssetId.TSLA) || 0n) <
                requestedTokens
              );
              // pagination had more than 1 page
              expect(utxo.length).toBeGreaterThan(pageSize);
            });

            it('when requested coins amount cannot be resolved, returns null', async () => {
              expect(await getUtxoFiltered(99_999_999_999_999_999n, 1n, { limit: 1, page: 0 })).toBeNull();
            });

            it('when requested tokens amount cannot be resolved, returns null', async () => {
              expect(await getUtxoFiltered(1n, 99_999_999_999_999_999n, { limit: 1, page: 0 })).toBeNull();
            });
          });
        });
      });

      describe('api.getCollateral', () => {
        // Wallet 2
        let wallet2: BaseWallet;
        let api2: WithSenderContext<WalletApi>;

        // Wallet 3
        let wallet3: BaseWallet;
        let api3: WithSenderContext<WalletApi>;

        // Wallet 4
        let wallet4: BaseWallet;
        let api4: WithSenderContext<WalletApi>;

        // Wallet 5
        let wallet5: BaseWallet;
        let api5: WithSenderContext<WalletApi>;

        // Wallet 6
        let wallet6: BaseWallet;
        let api6: WithSenderContext<WalletApi>;

        // Wallet 7
        let wallet7: BaseWallet;
        let api7: WithSenderContext<WalletApi>;

        beforeAll(async () => {
          // CREATE A WALLET WITH LOW COINS UTxOs
          ({ wallet: wallet2, api: api2 } = await createWalletAndApiWithStores(utxosWithLowCoins));

          // CREATE A WALLET WITH NO UTxOS
          ({ wallet: wallet3, api: api3 } = await createWalletAndApiWithStores([]));

          // CREATE A WALLET WITH UTxOS WITH ASSETS
          ({ wallet: wallet4, api: api4 } = await createWalletAndApiWithStores([mockUtxo[1], mockUtxo[2]]));

          // CREATE WALLET WITH CALLBACK FOR GET COLLATERAL (UNSPENDABLES DOES NOT FULFILL AMOUNT, AVAILABLE UTxOs WITH MIXED ASSETS)
          ({ wallet: wallet5, api: api5 } = await createWalletAndApiWithStores(
            utxosWithLowCoins,
            providers,
            mockCollateralCallback,
            true,
            utxosWithLowCoinsAndMixedAssets
          ));

          // CREATE WALLET WITH CALLBACK FOR GET COLLATERAL (NO UNSPENDABLES, AVAILABLE UTxOs WITH MIXED ASSETS)
          ({ wallet: wallet6, api: api6 } = await createWalletAndApiWithStores(
            [],
            providers,
            mockCollateralCallback,
            true,
            utxosWithLowCoinsAndMixedAssets
          ));

          // WALLET WITH CALLBACK FOR GET COLLATERAL (UNSPENDABLES DOES NOT FULFILL AMOUNT, NO AVAILABLE UTxOS)
          ({ wallet: wallet7, api: api7 } = await createWalletAndApiWithStores(
            utxosWithLowCoins,
            providers,
            mockCollateralCallback,
            true,
            []
          ));
        });

        afterAll(() => {
          wallet2.shutdown();
          wallet3.shutdown();
          wallet4.shutdown();
        });

        beforeEach(() => {
          mockCollateralCallback.mockClear();
        });

        test('can handle serialization errors', async () => {
          // YYYY is invalid hex that will throw at serialization
          await expect(api.getCollateral(context, { amount: 'YYYY' })).rejects.toThrowError(ApiError);
        });

        it('executes collateral callback if provided and unspendable UTxOs do not meet amount required', async () => {
          const collateral = await api5.getCollateral(context);
          expect(mockCollateralCallback).toHaveBeenCalledWith({
            data: {
              amount: 5_000_000n,
              utxos: sortedUtxosWithLowCoins
            },
            sender: {
              url: 'https://lace.io'
            },
            type: 'get_collateral'
          });

          expect(collateral).toEqual([Serialization.TransactionUnspentOutput.fromCore(mockUtxo[3]).toCbor()]);
          wallet5.shutdown();
        });

        it('executes collateral callback if provided and no unspendable UTxOs are available', async () => {
          const collateral = await api6.getCollateral(context);
          expect(mockCollateralCallback).toHaveBeenCalledWith({
            data: {
              amount: 5_000_000n,
              utxos: sortedUtxosWithLowCoins
            },
            sender: {
              url: 'https://lace.io'
            },
            type: 'get_collateral'
          });

          expect(collateral).toEqual([Serialization.TransactionUnspentOutput.fromCore(mockUtxo[3]).toCbor()]);
          wallet6.shutdown();
        });

        it('does not execute collateral callback if provided with no available UTxOs', async () => {
          await expect(api7.getCollateral(context)).rejects.toThrow(ApiError);
          expect(mockCollateralCallback).not.toHaveBeenCalled();
          wallet7.shutdown();
        });

        it('does not execute collateral callback if not provided', async () => {
          await expect(api2.getCollateral(context)).rejects.toThrow(ApiError);
          expect(mockCollateralCallback).not.toHaveBeenCalled();
        });

        test('accepts amount as tagged integer', async () => {
          await expect(api.getCollateral(context, { amount: 'c2434c4b40' })).resolves.not.toThrow();
        });

        test('returns multiple UTxOs when more than 1 utxo needed to satisfy amount', async () => {
          // 1a003d0900 Represents a BigNum object of 4 ADA
          const utxos = await api2.getCollateral(context, { amount: '1a003d0900' });
          // eslint-disable-next-line sonarjs/no-identical-functions

          expect(() =>
            utxos!.map((utxo) => Serialization.TransactionUnspentOutput.fromCbor(HexBlob(utxo)))
          ).not.toThrow();
          expect(utxos).toHaveLength(2);
        });

        test('throws when there are not enough UTxOs', async () => {
          // 1a004c4b40 Represents a BigNum object of 5 ADA
          await expect(api2.getCollateral(context, { amount: '1a004c4b40' })).rejects.toThrow(ApiError);
        });

        test('returns null when there are no "unspendable" UTxOs in the wallet', async () => {
          // 1a003d0900 Represents a BigNum object of 4 ADA
          expect(await api3.getCollateral(context, { amount: '1a003d0900' })).toBe(null);
          wallet3.shutdown();
        });

        test('throws when the given amount is greater than max amount', async () => {
          // 1a005b8d80 Represents a BigNum object of 6 ADA
          await expect(api2.getCollateral(context, { amount: '1a005b8d80' })).rejects.toThrow(ApiError);
        });

        test('returns first UTxO when amount is 0', async () => {
          // 00 Represents a BigNum object of 0 ADA
          const utxos = await api2.getCollateral(context, { amount: '00' });
          // eslint-disable-next-line sonarjs/no-identical-functions
          expect(() =>
            utxos!.map((utxo) => Serialization.TransactionUnspentOutput.fromCbor(HexBlob(utxo)))
          ).not.toThrow();
        });

        test('returns all UTxOs when there is no given amount', async () => {
          const utxos = await api.getCollateral(context);
          // eslint-disable-next-line sonarjs/no-identical-functions
          expect(() =>
            utxos!.map((utxo) => Serialization.TransactionUnspentOutput.fromCbor(HexBlob(utxo)))
          ).not.toThrow();
          expect(utxos).toHaveLength(1);
        });

        test('returns null when there is no given amount and wallet has no UTxOs', async () => {
          expect(await api3.getCollateral(context)).toBe(null);
        });

        test('throws when unspendable UTxOs contain assets', async () => {
          await expect(api4.getCollateral(context)).rejects.toThrow(ApiError);
        });
      });

      test('api.getBalance', async () => {
        const balanceCborBytes = await api.getBalance(context);
        expect(() => Serialization.Value.fromCbor(HexBlob(balanceCborBytes))).not.toThrow();
      });

      test('api.getUsedAddresses', async () => {
        const cipUsedAddressess = await api.getUsedAddresses(context);
        const usedAddresses = (await firstValueFrom(wallet.addresses$)).map((grouped) => grouped.address);

        expect(cipUsedAddressess.length).toBeGreaterThan(1);
        expect(cipUsedAddressess.map((cipAddr) => Cardano.PaymentAddress(cipAddr))).toEqual(usedAddresses);
      });

      test('api.getUnusedAddresses', async () => {
        const cipUsedAddressess = await api.getUnusedAddresses(context);
        expect(cipUsedAddressess).toEqual([]);
      });

      test('api.getChangeAddress', async () => {
        const cipChangeAddress = await api.getChangeAddress(context);
        const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
        expect(Cardano.PaymentAddress(cipChangeAddress)).toEqual(walletAddress);
      });

      test('api.getRewardAddresses', async () => {
        const cipRewardAddressesCbor = await api.getRewardAddresses(context);
        const cipRewardAddresses = cipRewardAddressesCbor.map((cipAddr) =>
          Cardano.Address.fromBytes(HexBlob(cipAddr)).toBech32()
        );

        const walletAddresses = await firstValueFrom(wallet.addresses$);
        const rewardAccounts = uniq(walletAddresses.map((address) => address.rewardAccount));
        expect(rewardAccounts.length).toBeGreaterThanOrEqual(1);
        expect(cipRewardAddresses).toEqual(rewardAccounts);
        expect(cipRewardAddressesCbor.length).toEqual(rewardAccounts.length);
      });

      describe('api.signTx', () => {
        let finalizedTx: Cardano.Tx;
        let hexTx: TxCBOR;

        beforeEach(async () => {
          const txInternals: InitializeTxResult = await wallet.initializeTx(simpleTxProps);
          finalizedTx = await signTx({
            addresses$: wallet.addresses$,
            tx: txInternals,
            walletUtil: wallet.util
          });
          hexTx = Serialization.Transaction.fromCore(finalizedTx).toCbor();
        });

        it('resolves with TransactionWitnessSet', async () => {
          const cip30witnessSet = await api.signTx(context, hexTx);
          expect(() => Serialization.TransactionWitnessSet.fromCbor(HexBlob(cip30witnessSet))).not.toThrow();
        });

        it('passes through sender from dapp connector context', async () => {
          const finalizeTxSpy = jest.spyOn(wallet, 'finalizeTx');
          await api.signTx(context, hexTx);
          expect(finalizeTxSpy).toBeCalledWith(
            expect.objectContaining({
              signingContext: {
                sender: {
                  url: context.sender.url
                }
              }
            })
          );
          expect(confirmationCallback.signTx).toBeCalledWith(expect.objectContaining({ sender: context.sender }));
        });
      });

      describe('api.signData', () => {
        test('sign with address', async () => {
          const [{ address }] = await firstValueFrom(wallet.addresses$);
          const cip30dataSignature = await api.signData(context, address, HexBlob('abc123'));
          expect(typeof cip30dataSignature.key).toBe('string');
          expect(typeof cip30dataSignature.signature).toBe('string');
        });

        test('sign with bech32 DRepID', async () => {
          const dRepKey = await api.getPubDRepKey(context);
          const drepid = buildDRepIDFromDRepKey(dRepKey);

          const cip95dataSignature = await api.signData(context, drepid, HexBlob('abc123'));
          expect(typeof cip95dataSignature.key).toBe('string');
          expect(typeof cip95dataSignature.signature).toBe('string');
        });

        test('rejects if bech32 DRepID is not a type 6 address', async () => {
          const dRepKey = await api.getPubDRepKey(context);
          for (const type in Cardano.AddressType) {
            if (!Number.isNaN(Number(type)) && Number(type) !== Cardano.AddressType.EnterpriseKey) {
              const drepid = buildDRepIDFromDRepKey(dRepKey, 0, type as unknown as Cardano.AddressType);
              await expect(api.signData(context, drepid, HexBlob('abc123'))).rejects.toThrow();
            }
          }
        });

        it('passes through sender from dapp connector context', async () => {
          const [{ address }] = await firstValueFrom(wallet.addresses$);
          const signDataSpy = jest.spyOn(wallet, 'signData');
          await api.signData(context, address, HexBlob('abc123'));
          expect(signDataSpy).toBeCalledWith(
            expect.objectContaining({
              sender: {
                url: context.sender.url
              }
            })
          );
          expect(confirmationCallback.signData).toBeCalledWith(expect.objectContaining({ sender: context.sender }));
        });
      });

      describe('api.submitTx', () => {
        let finalizedTx: Cardano.Tx;
        let txBytes: Uint8Array;
        let hexTx: string;

        beforeEach(async () => {
          const txInternals = await wallet.initializeTx(simpleTxProps);
          finalizedTx = await wallet.finalizeTx({ tx: txInternals });
          hexTx = Serialization.Transaction.fromCore(finalizedTx).toCbor();
          txBytes = Buffer.from(hexTx, 'hex');
        });

        it('resolves with transaction id when submitting a valid transaction', async () => {
          const txId = await api.submitTx(context, hexTx);
          expect(txId).toBe(finalizedTx.id);
        });

        // Need to find a transaction that body can't be consistently re-serialized by using our serialization utils
        it.todo('resolves with original transactionId (not the one computed when re-serializing the transaction)');

        it('throws ApiError when submitting a transaction that has invalid encoding', async () => {
          await expect(api.submitTx(context, Buffer.from(txBytes).toString('base64'))).rejects.toThrowError(ApiError);
        });

        it('throws ApiError when submitting a hex string that is not a serialized transaction', async () => {
          await expect(api.submitTx(context, Buffer.from([0, 1, 3]).toString('hex'))).rejects.toThrowError(ApiError);
        });

        it('throws TxSendError when submission fails', async () => {
          providers.txSubmitProvider.submitTx.mockRejectedValueOnce(
            new TxSubmissionError(
              TxSubmissionErrorCode.OutsideOfValidityInterval,
              {
                currentSlot: 5,
                validityInterval: { invalidBefore: 6, invalidHereafter: 7 }
              } as OutsideOfValidityIntervalData,
              'Outside of validity interval'
            )
          );
          await expect(api.submitTx(context, hexTx)).rejects.toThrowError(TxSendError);
        });
      });

      describe('api.getPubDRepKey', () => {
        test("returns the DRep key derived from the wallet's public key", async () => {
          const cip95PubDRepKey = await api.getPubDRepKey(context);
          expect(cip95PubDRepKey).toEqual(await wallet.governance.getPubDRepKey());
        });
        test('throws an ApiError on unexpected error', async () => {
          (wallet.governance.getPubDRepKey as jest.Mock).mockRejectedValueOnce(new Error('unexpected error'));
          try {
            await api.getPubDRepKey(context);
          } catch (error) {
            expect(error instanceof ApiError).toBe(true);
            expect((error as ApiError).code).toEqual(APIErrorCode.InternalError);
            expect((error as ApiError).info).toEqual('unexpected error');
          }
          // fails the test if it does not throw
          expect.assertions(3);
        });
      });

      test('api.getExtensions', async () => {
        const extensions = await api.getExtensions(context);
        expect(extensions).toEqual([{ cip: 95 }]);
      });
    });

    describe('confirmation callbacks', () => {
      let address: Cardano.PaymentAddress;

      beforeEach(async () => {
        address = (await firstValueFrom(wallet.addresses$))[0].address;
      });

      describe('signData', () => {
        const payload = 'abc123';

        test('resolves true', async () => {
          confirmationCallback.signData = jest.fn().mockResolvedValueOnce(true);
          await expect(api.signData(context, address, payload)).resolves.not.toThrow();
        });

        test('resolves false', async () => {
          confirmationCallback.signData = jest.fn().mockResolvedValueOnce(false);
          await expect(api.signData(context, address, payload)).rejects.toThrowError(DataSignError);
        });

        test('rejects', async () => {
          confirmationCallback.signData = jest.fn().mockRejectedValue(1);
          await expect(api.signData(context, address, payload)).rejects.toThrowError(DataSignError);
        });

        test('gets the Cardano.Address equivalent of the hex address', async () => {
          confirmationCallback.signData = jest.fn().mockResolvedValueOnce(true);

          const hexAddr = Cardano.Address.fromBech32(address).toBytes();

          await api.signData(context, hexAddr, payload);
          expect(confirmationCallback.signData).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ addr: address }) })
          );
        });
      });

      describe('signTx', () => {
        let hexTx: string;
        beforeAll(async () => {
          const txInternals = await wallet.initializeTx(simpleTxProps);
          const finalizedTx = await signTx({ addresses$: wallet.addresses$, tx: txInternals, walletUtil: wallet.util });
          hexTx = Serialization.Transaction.fromCore(finalizedTx).toCbor();
        });

        test('resolves true', async () => {
          confirmationCallback.signTx = jest.fn().mockResolvedValueOnce(true);
          await expect(api.signTx(context, hexTx)).resolves.not.toThrow();
        });

        test('resolves false', async () => {
          confirmationCallback.signTx = jest.fn().mockResolvedValueOnce(false);
          await expect(api.signTx(context, hexTx)).rejects.toThrowError(TxSignError);
        });

        test('rejects', async () => {
          confirmationCallback.signTx = jest.fn().mockRejectedValue(1);
          await expect(api.signTx(context, hexTx)).rejects.toThrowError(TxSignError);
        });
      });

      describe('submitTx', () => {
        let serializedTx: string;
        let txInternals: InitializeTxResult;
        let finalizedTx: Cardano.Tx<Cardano.TxBody>;

        beforeAll(async () => {
          txInternals = await wallet.initializeTx(simpleTxProps);
          finalizedTx = await wallet.finalizeTx({ tx: txInternals });
          serializedTx = Serialization.Transaction.fromCore(finalizedTx).toCbor();
        });

        test('resolves true', async () => {
          confirmationCallback.submitTx = jest.fn().mockResolvedValueOnce(true);
          await expect(api.submitTx(context, serializedTx)).resolves.toBe(finalizedTx.id);
        });

        test('resolves false', async () => {
          confirmationCallback.submitTx = jest.fn().mockResolvedValueOnce(false);
          await expect(api.submitTx(context, serializedTx)).rejects.toThrowError(TxSendError);
        });

        test('rejects', async () => {
          confirmationCallback.submitTx = jest.fn().mockRejectedValue(1);
          await expect(api.submitTx(context, serializedTx)).rejects.toThrowError(TxSendError);
        });
      });
    });

    describe('ProofGeneration errors', () => {
      const address = mocks.utxo[0][0].address!;
      let txSubmitProvider: mocks.TxSubmitProviderStub;
      let networkInfoProvider: mocks.NetworkInfoProviderStub;
      let mockWallet: BaseWallet;
      let utxoProvider: mocks.UtxoProviderStub;
      let tx: Cardano.Tx;
      let mockApi: WithSenderContext<WalletApi>;

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
          stakeKeyDerivationPath,
          type: AddressType.External
        };
        const asyncKeyAgent = await testAsyncKeyAgent();
        const bip32Account = await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent);
        bip32Account.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
        mockWallet = createPersonalWallet(
          { name: 'Test Wallet' },
          {
            assetProvider,
            bip32Account,
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

        await waitForWalletStateSettle(mockWallet);
        mockApi = cip30.createWalletApi(
          of(mockWallet),
          {
            signData: jest.fn().mockResolvedValue(true),
            signTx: jest.fn().mockResolvedValue(true),
            submitTx: jest.fn().mockResolvedValue(true)
          },
          { logger }
        );

        const props = {
          certificates: [
            {
              __typename: Cardano.CertificateType.StakeDeregistration,
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
                type: Cardano.CredentialType.KeyHash
              }
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

        tx = await signTx({
          addresses$: mockWallet.addresses$,
          tx: await mockWallet.initializeTx(props),
          walletUtil: mockWallet.util
        });
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
          await expect(mockApi.signTx(context, cbor, false)).resolves.not.toThrow();
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
          await expect(mockApi.signTx(context, cbor, true)).resolves.not.toThrow();
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
          await expect(mockApi.signTx(context, cbor, true)).resolves.not.toThrow();
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
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
                type: Cardano.CredentialType.KeyHash
              }
            } as Cardano.StakeDelegationCertificate,
            ...tx.body.certificates!
          ];

          mockWallet.finalizeTx = () => Promise.resolve(tx as unknown as Cardano.Tx);

          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(2);
          await expect(mockApi.signTx(context, cbor, true)).resolves.not.toThrow();
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

          await expect(mockApi.signTx(context, cbor, true)).rejects.toMatchObject(
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

          await expect(mockApi.signTx(context, cbor, false)).rejects.toMatchObject(
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
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
                type: Cardano.CredentialType.KeyHash
              }
            } as Cardano.StakeDelegationCertificate,
            ...tx.body.certificates!
          ];

          const cbor = TxCBOR.serialize(tx);

          // Inputs are selected by input selection algorithm
          expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
          expect(tx.body.certificates!.length).toBe(2);

          await expect(mockApi.signTx(context, cbor, false)).rejects.toMatchObject(
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
