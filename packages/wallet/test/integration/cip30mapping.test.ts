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
  TxSignErrorCode,
  WalletApi,
  WithSenderContext
} from '@cardano-sdk/dapp-connector';
import { AddressType, Bip32Account, GroupedAddress, KeyRole, util } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { BaseWallet, ObservableWallet, cip30, createPersonalWallet } from '../../src';
import { CallbackConfirmation, GetCollateralCallbackParams } from '../../src/cip30';
import {
  Cardano,
  OutsideOfValidityIntervalData,
  Serialization,
  TxSubmissionError,
  TxSubmissionErrorCode,
  coalesceValueQuantities
} from '@cardano-sdk/core';
import { HexBlob, ManagedFreeableScope } from '@cardano-sdk/util';
import { InMemoryUnspendableUtxoStore, createInMemoryWalletStores } from '../../src/persistence';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { NEVER, firstValueFrom, of } from 'rxjs';
import { Providers, createWallet } from './util';
import { address_0_0, address_1_0, rewardAccount_0, rewardAccount_1 } from '../services/ChangeAddress/testData';
import { buildDRepAddressFromDRepKey, signTx, waitForWalletStateSettle } from '../util';
import { dummyLogger as logger } from 'ts-log';
import { stakeKeyDerivationPath, testAsyncKeyAgent } from '../../../key-management/test/mocks';
import uniq from 'lodash/uniq.js';

const {
  mockChainHistoryProvider,
  mockDrepProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  utxo: mockUtxo,
  utxosWithLowCoins,
  utxosWithLowCoinsAndMixedAssets,
  sortedUtxosWithLowCoins,
  impureUtxos
} = mocks;

type TestProviders = Required<Pick<Providers, 'txSubmitProvider' | 'networkInfoProvider'>>;
const mockCollateralCallback = jest.fn().mockResolvedValue([mockUtxo[3]]);
const createMockGenericCallback = <T>(result: T) => jest.fn().mockResolvedValue(result);
const foreignTx = Serialization.TxCBOR(
  '84a70081825820dce442e983f3f5cd5b2644bc57f749075390f1fbae9ab55bf454342959c885db00018182583900d161d64eef0eeb59f9124f520f8c8f3b717ed04198d54c8b17e604aea63c153fb3ea8a4ea4f165574ea91173756de0bf30222ca0e95a649a1a0082607b021a0016360509a1581cb77934706fa311b6568d1070c2d23f092324b35ad623aa571a0e3726a14e4d6573685f476966745f43617264200b5820d8175f3b1276a48939a6ccee220a7f81b6422167317ba3ff6325cba1fb6ccbe70d818258208d68748457cd0f1a8596f41fd2125a415315897d2da4a4b94335829cee7198ae001281825820dce442e983f3f5cd5b2644bc57f749075390f1fbae9ab55bf454342959c885db00a2068259016b590168010000333232323232323223223222253330083232533300d3010002132533300b3370e6eb4c034009200113371e0020122940dd718058008b180700099299980499b8748008c028dd50008a5eb7bdb1804dd5980718059baa001323300100132330010013756601e602060206020602060186ea8c03cc030dd50019129998070008a5eb7bdb1804c8c8c8c94ccc03ccdc8a45000021533300f3371e91010000210031005133013337606ea4008dd3000998030030019bab3010003375c601c0046024004602000244a66601a002298103d87a8000132323232533300e337220140042a66601c66e3c0280084cdd2a4000660246e980052f5c02980103d87a80001330060060033756601e0066eb8c034008c044008c03c00452613656375c0026eb80055cd2ab9d5573caae7d5d02ba157449810f4e4d6573685f476966745f43617264004c011e581cb77934706fa311b6568d1070c2d23f092324b35ad623aa571a0e3726000159023c59023901000033323232323232322322232323225333009323232533300c3007300d3754002264646464a666026602c00426464a666024601a60266ea803854ccc048c034c04cdd5191980080080311299980b8008a60103d87a80001323253330163375e603660306ea800804c4cdd2a40006603400497ae0133004004001301b002301900115333012300c00113371e00402029405854ccc048cdc3800a4002266e3c0080405281bad3013002375c60220022c602800264a66601e601260206ea800452f5bded8c026eacc050c044dd500099191980080099198008009bab3016301730173017301700522533301500114bd6f7b630099191919299980b19b91488100002153330163371e9101000021003100513301a337606ea4008dd3000998030030019bab3017003375c602a0046032004602e00244a666028002298103d87a800013232323253330153372200e0042a66602a66e3c01c0084cdd2a4000660326e980052f5c02980103d87a80001330060060033756602c0066eb8c050008c060008c058004dd7180998081baa00337586024002601c6ea800858c040c044008c03c004c02cdd50008a4c26cac64a66601060060022a66601660146ea8010526161533300830020011533300b300a37540082930b0b18041baa003370e90011b8748000dd7000ab9a5573aaae7955cfaba05742ae8930010f4e4d6573685f476966745f43617264004c012bd8799fd8799f58203159a6f2ae24c5bfbed947fe0ecfe936f088c8d265484e6979cacb607d33c811ff05ff0001058284000040821a006acfc01ab2d05e00840100d87a80821a006acfc01ab2d05e00f5f6'
);

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
    signData: createMockGenericCallback({ cancel$: NEVER }),
    signTx: createMockGenericCallback({ cancel$: NEVER }),
    submitTx: createMockGenericCallback(true),
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
          const serializedTx = Serialization.TxCBOR(
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

      // eslint-disable-next-line max-statements
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

        // Wallet 8
        let wallet8: BaseWallet;
        let api8: WithSenderContext<WalletApi>;

        // Wallet 9
        let wallet9: BaseWallet;
        let api9: WithSenderContext<WalletApi>;

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

          // WALLET WITH CALLBACK FOR GET COLLATERAL (BRAND NEW WALLET, NO UTXOS)
          ({ wallet: wallet8, api: api8 } = await createWalletAndApiWithStores(
            [],
            providers,
            mockCollateralCallback,
            true,
            []
          ));

          // WALLET WITH CALLBACK FOR GET COLLATERAL (ONLY IMPURE UTXOs)
          ({ wallet: wallet9, api: api9 } = await createWalletAndApiWithStores(
            [],
            providers,
            mockCollateralCallback,
            true,
            impureUtxos
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

        it('does not execute collateral callback and returns null if brand new wallet (no UTXOS)', async () => {
          await expect(api8.getCollateral(context)).resolves.toBeNull();
          expect(mockCollateralCallback).not.toHaveBeenCalled();
          wallet8.shutdown();
        });

        it('does executes collateral callback with empty array if wallet has only impure UTXOS', async () => {
          await expect(api9.getCollateral(context)).resolves.not.toBeNull();
          expect(mockCollateralCallback).toHaveBeenCalledWith({
            data: {
              amount: 5_000_000n,
              utxos: []
            },
            sender: {
              url: 'https://lace.io'
            },
            type: 'get_collateral'
          });
          wallet9.shutdown();
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
        const cipUsedAddresses = await api.getUsedAddresses(context);
        const usedAddresses = (await firstValueFrom(wallet.addresses$)).map((grouped) => grouped.address);

        expect(cipUsedAddresses.length).toBe(1);
        expect(cipUsedAddresses).toEqual([Cardano.Address.fromString(usedAddresses[1])!.toBytes()]);
      });

      test('api.getUsedAddresses returns empty array if no used addresses found', async () => {
        const address = {
          accountIndex: 0,
          address: address_0_0,
          index: 0,
          networkId: Cardano.NetworkId.Testnet,
          rewardAccount: rewardAccount_0,
          stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
          type: AddressType.External
        };

        const newApi = cip30.createWalletApi(
          of({
            addresses$: of([address]),
            getNextUnusedAddress: () => [address]
          } as unknown as ObservableWallet),
          confirmationCallback,
          { logger }
        );

        const cipUsedAddresses = await newApi.getUsedAddresses(context);

        expect(cipUsedAddresses).toEqual([]);
      });

      test('api.getUnusedAddresses', async () => {
        const addresses = (await firstValueFrom(wallet.addresses$)).map((grouped) => grouped.address);
        const cipUnusedAddresses = await api.getUnusedAddresses(context);
        expect(cipUnusedAddresses).toEqual([Cardano.Address.fromString(addresses[0])!.toBytes()]);
      });

      test('api.getChangeAddress', async () => {
        const cipChangeAddress = await api.getChangeAddress(context);
        const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
        expect(Cardano.PaymentAddress(cipChangeAddress)).toEqual(walletAddress);
      });

      test('api.getChangeAddress always returns the lowest payment key derivation index', async () => {
        const addresses = [
          {
            accountIndex: 0,
            address: address_0_0,
            index: 0,
            networkId: Cardano.NetworkId.Testnet,
            rewardAccount: rewardAccount_0,
            stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
            type: AddressType.External
          },
          {
            accountIndex: 0,
            address: address_1_0,
            index: 1,
            networkId: Cardano.NetworkId.Testnet,
            rewardAccount: rewardAccount_1,
            stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
            type: AddressType.External
          }
        ];

        const newApi = cip30.createWalletApi(
          of({
            addresses$: of(addresses), // these are guaranteed to be sorted
            getNextUnusedAddress: () => [addresses[1]]
          } as unknown as ObservableWallet),
          confirmationCallback,
          { logger }
        );

        const cipChangeAddress = await newApi.getChangeAddress(context);
        expect(Cardano.PaymentAddress(cipChangeAddress)).toEqual(address_0_0);
      });

      test('api.getChangeAddress if is script wallet do not sort and return the first address found', async () => {
        const addresses = [
          {
            address: address_1_0,
            networkId: Cardano.NetworkId.Testnet,
            rewardAccount: rewardAccount_1,
            scripts: {}
          },
          {
            address: address_0_0,
            networkId: Cardano.NetworkId.Testnet,
            rewardAccount: rewardAccount_1,
            scripts: {}
          }
        ];

        const newApi = cip30.createWalletApi(
          of({
            addresses$: of(addresses),
            getNextUnusedAddress: () => [addresses[1]]
          } as unknown as ObservableWallet),
          confirmationCallback,
          { logger }
        );

        const cipChangeAddress = await newApi.getChangeAddress(context);
        expect(Cardano.PaymentAddress(cipChangeAddress)).toEqual(address_1_0);
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
        let hexTx: Serialization.TxCBOR;

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
          const finalizeTxSpy = jest.spyOn(wallet, 'finalizeTx').mockClear();

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

        it('doesnt invoke confirmationCallback.signTx if an error occurs', async () => {
          const finalizeTxSpy = jest.spyOn(wallet, 'finalizeTx').mockClear();
          confirmationCallback.signTx = jest.fn().mockResolvedValueOnce({ cancel$: NEVER }).mockClear();

          await expect(api.signTx(context, foreignTx, false)).rejects.toThrowError();
          expect(finalizeTxSpy).not.toHaveBeenCalled();
          expect(confirmationCallback.signTx).not.toHaveBeenCalled();
        });

        it('rejects with UserDeclined error if cancel$ emits before finalizeTx resolves', async () => {
          jest.spyOn(wallet, 'finalizeTx').mockResolvedValueOnce(
            new Promise(() => {
              // never resolves or rejects
            })
          );
          confirmationCallback.signTx = jest.fn().mockResolvedValueOnce({ cancel$: of(void 0) });

          await expect(api.signTx(context, hexTx)).rejects.toThrowError(
            expect.objectContaining({ code: TxSignErrorCode.UserDeclined })
          );
        });
      });

      describe('api.signData', () => {
        beforeEach(() => {
          jest.clearAllMocks();
        });

        test('sign with bech32 address', async () => {
          const [{ address }] = await firstValueFrom(wallet.addresses$);
          const cip30dataSignature = await api.signData(context, address, HexBlob('abc123'));
          expect(typeof cip30dataSignature.key).toBe('string');
          expect(typeof cip30dataSignature.signature).toBe('string');
        });

        test('sign with hex-encoded address', async () => {
          const signDataSpy = jest.spyOn(wallet, 'signData');
          const [{ address }] = await firstValueFrom(wallet.addresses$);
          const addressHex = Cardano.Address.fromString(address)?.toBytes();
          if (!addressHex) {
            expect(addressHex).toBeDefined();
            return;
          }
          const cip30dataSignature = await api.signData(context, addressHex, HexBlob('abc123'));
          expect(typeof cip30dataSignature.key).toBe('string');
          expect(typeof cip30dataSignature.signature).toBe('string');
          expect(signDataSpy.mock.calls[0][0].signWith).toEqual(address);
        });

        test('sign with bech32 reward account', async () => {
          const signDataSpy = jest.spyOn(wallet, 'signData');
          const [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);

          const cip30dataSignature = await api.signData(context, rewardAccount, HexBlob('abc123'));
          expect(typeof cip30dataSignature.key).toBe('string');
          expect(typeof cip30dataSignature.signature).toBe('string');
          expect(signDataSpy.mock.calls[0][0].signWith).toEqual(rewardAccount);
        });

        test('sign with hex-encoded reward account', async () => {
          const signDataSpy = jest.spyOn(wallet, 'signData');
          const [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);
          const rewardAccountHex = Cardano.Address.fromString(rewardAccount)?.toBytes();

          const cip30dataSignature = await api.signData(context, rewardAccountHex!, HexBlob('abc123'));
          expect(typeof cip30dataSignature.key).toBe('string');
          expect(typeof cip30dataSignature.signature).toBe('string');
          expect(signDataSpy.mock.calls[0][0].signWith).toEqual(rewardAccount);
        });

        test('sign with hex-encoded DRepID key hash hex', async () => {
          const signDataSpy = jest.spyOn(wallet, 'signData');
          const dRepKey = await api.getPubDRepKey(context);
          const drepKeyHashHex = (await Crypto.Ed25519PublicKey.fromHex(dRepKey).hash()).hex();

          await api.signData(context, drepKeyHashHex, HexBlob('abc123'));
          expect(signDataSpy).toHaveBeenCalledTimes(1);
          // Wallet signData is called with the DRepID as bech32 address because it was transformed by the cip30Api.
          // The address credential should be the drepKeyHash
          const signAddr = Cardano.Address.fromString(signDataSpy.mock.calls[0][0].signWith);
          expect(signAddr?.getProps().paymentPart?.hash).toEqual(drepKeyHashHex);
        });

        test('sign with hex-encoded type 6 DRepID address', async () => {
          const signDataSpy = jest.spyOn(wallet, 'signData');
          const dRepKey = await api.getPubDRepKey(context);
          const drepKeyHashHex = (await Crypto.Ed25519PublicKey.fromHex(dRepKey).hash()).hex();
          const drepAddress = await buildDRepAddressFromDRepKey(dRepKey);
          // CIP95 DRepID as type 6 hex-encoded Address
          const drepAddressBytes = drepAddress?.toAddress()?.toBytes();

          if (!drepAddressBytes) {
            expect(drepAddressBytes).toBeDefined();
            return;
          }

          await api.signData(context, drepAddressBytes, HexBlob('abc123'));
          expect(signDataSpy).toHaveBeenCalledTimes(1);
          // Wallet signData is called with the DRepID as bech32 address because it was transformed by the cip30Api.
          // The address credential should be the drepKeyHash
          const signAddr = Cardano.Address.fromString(signDataSpy.mock.calls[0][0].signWith);
          expect(signAddr?.getProps().paymentPart?.hash).toEqual(drepKeyHashHex);
        });

        test('sign with bech32 type 6 DRepID address', async () => {
          const signDataSpy = jest.spyOn(wallet, 'signData');
          const dRepKey = await api.getPubDRepKey(context);
          const drepKeyHashHex = (await Crypto.Ed25519PublicKey.fromHex(dRepKey).hash()).hex();
          const drepAddress = await buildDRepAddressFromDRepKey(dRepKey);
          // CIP95 DRepID as type 6 hex-encoded Address
          const drepAddressBech32 = drepAddress?.toAddress()?.toBech32();

          if (!drepAddressBech32) {
            expect(drepAddressBech32).toBeDefined();
            return;
          }

          await api.signData(context, drepAddressBech32, HexBlob('abc123'));
          expect(signDataSpy).toHaveBeenCalledTimes(1);
          // Wallet signData is called with the DRepID as bech32 address because it was transformed by the cip30Api.
          // The address credential should be the drepKeyHash
          const signAddr = Cardano.Address.fromString(signDataSpy.mock.calls[0][0].signWith);
          expect(signAddr?.getProps().paymentPart?.hash).toEqual(drepKeyHashHex);
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

        it('rejects with UserDeclined error if cancel$ emits before finalizeTx resolves', async () => {
          const [{ address }] = await firstValueFrom(wallet.addresses$);
          jest.spyOn(wallet, 'signData').mockResolvedValueOnce(
            new Promise(() => {
              // never resolves or rejects
            })
          );
          confirmationCallback.signData = jest.fn().mockResolvedValueOnce({ cancel$: of(void 0) });

          await expect(api.signData(context, address, HexBlob('abc123'))).rejects.toThrowError(
            expect.objectContaining({ code: DataSignErrorCode.UserDeclined })
          );
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

        test('resolves ok', async () => {
          confirmationCallback.signData = jest.fn().mockResolvedValueOnce({ cancel$: NEVER });
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
          confirmationCallback.signData = jest.fn().mockResolvedValueOnce({ cancel$: NEVER });

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

        test('resolves ok', async () => {
          confirmationCallback.signTx = jest.fn().mockResolvedValueOnce({ cancel$: NEVER });
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
        const drepProvider = mockDrepProvider();
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
            drepProvider,
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
            signData: jest.fn().mockResolvedValue({ cancel$: NEVER }),
            signTx: jest.fn().mockResolvedValue({ cancel$: NEVER }),
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
          const cbor = Serialization.TxCBOR.serialize(tx);

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
          const cbor = Serialization.TxCBOR.serialize(tx);

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
          const cbor = Serialization.TxCBOR.serialize(tx);

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

          const cbor = Serialization.TxCBOR.serialize(tx);

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
          const cbor = Serialization.TxCBOR.serialize(tx);

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

          const cbor = Serialization.TxCBOR.serialize(tx);

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

          const cbor = Serialization.TxCBOR.serialize(tx);

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
