/* eslint-disable @typescript-eslint/no-explicit-any, sonarjs/no-duplicate-string */
import { ApiError, DataSignError, TxSendError, TxSignError, WalletApi } from '@cardano-sdk/dapp-connector';
import { CML, Cardano, cmlToCore, coreToCml } from '@cardano-sdk/core';
import { HexBlob, ManagedFreeableScope } from '@cardano-sdk/util';
import { InMemoryUnspendableUtxoStore, createInMemoryWalletStores } from '../../src/persistence';
import { InitializeTxProps, InitializeTxResult, SingleAddressWallet, cip30 } from '../../src';
import { createWallet } from './util';
import { firstValueFrom, of } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { utxo as mockedUtxo, utxosWithLowCoins } from '../mocks';
import { waitForWalletStateSettle } from '../util';

const createWalletAndApiWithStores = async (utxos: Cardano.Utxo[]) => {
  const unspendableUtxo = new InMemoryUnspendableUtxoStore();
  unspendableUtxo.setAll(utxos);
  const stores = { ...createInMemoryWalletStores(), unspendableUtxo };
  const { wallet } = await createWallet(stores);
  const confirmationCallback = jest.fn().mockResolvedValue(true);
  const api = cip30.createWalletApi(of(wallet), confirmationCallback, { logger });
  await waitForWalletStateSettle(wallet);
  return { api, confirmationCallback, wallet };
};

describe('cip30', () => {
  let wallet: SingleAddressWallet;
  let api: WalletApi;
  let confirmationCallback: jest.Mock;
  let scope: ManagedFreeableScope;

  const simpleTxProps: InitializeTxProps = {
    outputs: new Set([
      {
        address: Cardano.Address(
          // eslint-disable-next-line max-len
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 1_111_111n }
      }
    ])
  };

  beforeAll(async () => {
    // CREATE A WALLET
    scope = new ManagedFreeableScope();
    ({ wallet, api, confirmationCallback } = await createWalletAndApiWithStores([mockedUtxo[2]]));
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

    test('api.getCollateral', async () => {
      // 1a003d0900 Represents a CML.BigNum object of 4 ADA
      const utxos = await api.getCollateral({ amount: '1a003d0900' });
      // eslint-disable-next-line sonarjs/no-identical-functions
      expect(() =>
        cmlToCore.utxo(
          utxos!.map((utxo) => scope.manage(CML.TransactionUnspentOutput.from_bytes(Buffer.from(utxo, 'hex'))))
        )
      ).not.toThrow();
    });

    test('api.getBalance', async () => {
      const balanceCborBytes = Buffer.from(await api.getBalance(), 'hex');
      expect(() => scope.manage(CML.Value.from_bytes(balanceCborBytes))).not.toThrow();
    });

    test('api.getUsedAddresses', async () => {
      const cipUsedAddressess = await api.getUsedAddresses();
      const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
      expect(cipUsedAddressess.map((cipAddr) => Cardano.Address(cipAddr))).toEqual([walletAddress]);
    });

    test('api.getUnusedAddresses', async () => {
      const cipUsedAddressess = await api.getUnusedAddresses();
      expect(cipUsedAddressess).toEqual([]);
    });

    test('api.getChangeAddress', async () => {
      const cipChangeAddress = await api.getChangeAddress();
      const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
      expect(Cardano.Address(cipChangeAddress)).toEqual(walletAddress);
    });

    test('api.getRewardAddresses', async () => {
      const cipRewardAddressesCbor = await api.getRewardAddresses();
      const cipRewardAddresses = cipRewardAddressesCbor.map((cipAddr) =>
        scope.manage(CML.Address.from_bytes(Buffer.from(cipAddr, 'hex'))).to_bech32()
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
      const cip30dataSignature = await api.signData(address, HexBlob('abc123').toString());
      expect(typeof cip30dataSignature.key).toBe('string');
      expect(typeof cip30dataSignature.signature).toBe('string');
    });

    test('api.submitTx', async () => {
      const txInternals = await wallet.initializeTx(simpleTxProps);
      const finalizedTx = await wallet.finalizeTx({ tx: txInternals });
      const cmlTx = coreToCml.tx(scope, finalizedTx).to_bytes();
      await expect(api.submitTx(Buffer.from(cmlTx).toString('hex'))).resolves.not.toThrow();
    });

    test.todo('errorStates');
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

        const hexAddr = Buffer.from(scope.manage(CML.Address.from_bech32(expectedAddr.toString())).to_bytes()).toString(
          'hex'
        );

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

    describe('getCollateral', () => {
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
  });
});
