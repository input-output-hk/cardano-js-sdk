/* eslint-disable @typescript-eslint/no-explicit-any, sonarjs/no-duplicate-string */
import { CSL, Cardano, coreToCsl, cslToCore } from '@cardano-sdk/core';
import { DataSignError, TxSendError, TxSignError, WalletApi } from '@cardano-sdk/cip30';
import { InitializeTxProps, InitializeTxResult, SingleAddressWallet, cip30 } from '../../src';
import { createWallet } from './util';
import { firstValueFrom } from 'rxjs';
import { networkId } from '../mocks';
import { waitForWalletStateSettle } from '../util';

describe('cip30', () => {
  let wallet: SingleAddressWallet;
  let api: WalletApi;
  let confirmationCallback: jest.Mock;

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
    wallet = await createWallet();
    confirmationCallback = jest.fn().mockResolvedValue(true);
    api = cip30.createWalletApi(Promise.resolve(wallet), confirmationCallback);
    await waitForWalletStateSettle(wallet);
  });

  afterAll(() => {
    wallet.shutdown();
  });

  describe('createWalletApi', () => {
    test('api.getNetworkId', async () => {
      const cip30NetworkId = await api.getNetworkId();
      expect(cip30NetworkId).toEqual(networkId);
    });

    test('api.getUtxos', async () => {
      const utxos = await api.getUtxos();
      expect(() =>
        cslToCore.utxo(utxos!.map((utxo) => CSL.TransactionUnspentOutput.from_bytes(Buffer.from(utxo, 'hex'))))
      ).not.toThrow();
    });

    test('api.getBalance', async () => {
      const balanceCborBytes = Buffer.from(await api.getBalance(), 'hex');
      expect(() => CSL.Value.from_bytes(balanceCborBytes)).not.toThrow();
    });

    test('api.getUsedAddresses', async () => {
      const cipUsedAddressess = await api.getUsedAddresses();
      const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
      expect(cipUsedAddressess).toEqual([walletAddress]);
    });

    test('api.getUnusedAddresses', async () => {
      const cipUsedAddressess = await api.getUnusedAddresses();
      expect(cipUsedAddressess).toEqual([]);
    });

    test('api.getChangeAddress', async () => {
      const cipChangeAddress = await api.getChangeAddress();
      const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
      expect(cipChangeAddress).toEqual(walletAddress);
    });

    test('api.getRewardAddresses', async () => {
      const cipRewardAddresses = await api.getRewardAddresses();
      const [{ rewardAccount: walletRewardAccount }] = await firstValueFrom(wallet.addresses$);
      expect(cipRewardAddresses).toEqual([walletRewardAccount]);
    });

    test('api.signTx', async () => {
      const txInternals = await wallet.initializeTx(simpleTxProps);
      const finalizedTx = await wallet.finalizeTx(txInternals);
      const hexTxBody = Buffer.from(coreToCsl.tx(finalizedTx).body().to_bytes()).toString('hex');

      const cip30witnessSet = await api.signTx(hexTxBody);
      const signatures = Buffer.from(cip30witnessSet, 'hex');
      expect(() => CSL.TransactionWitnessSet.from_bytes(signatures)).not.toThrow();
    });

    test('api.signData', async () => {
      const [{ address }] = await firstValueFrom(wallet.addresses$);
      const cip30dataSignature = await api.signData(address, Cardano.util.HexBlob('abc123').toString());
      expect(typeof cip30dataSignature.key).toBe('string');
      expect(typeof cip30dataSignature.signature).toBe('string');
    });

    test('api.submitTx', async () => {
      const txInternals = await wallet.initializeTx(simpleTxProps);
      const finalizedTx = await wallet.finalizeTx(txInternals);

      const cslTx = coreToCsl.tx(finalizedTx).to_bytes();
      await expect(api.submitTx(Buffer.from(cslTx).toString('hex'))).resolves.not.toThrow();
    });

    test.todo('errorStates');
  });

  describe('confirmation callbacks', () => {
    describe('signData', () => {
      const payload = 'abc123';

      test('resolves true', async () => {
        confirmationCallback.mockResolvedValueOnce(true);
        await expect(api.signData(wallet.keyAgent.knownAddresses[0].address, payload)).resolves.not.toThrow();
      });

      test('resolves false', async () => {
        confirmationCallback.mockResolvedValueOnce(false);
        await expect(api.signData(wallet.keyAgent.knownAddresses[0].address, payload)).rejects.toThrowError(
          DataSignError
        );
      });

      test('rejects', async () => {
        confirmationCallback.mockRejectedValue(1);
        await expect(api.signData(wallet.keyAgent.knownAddresses[0].address, payload)).rejects.toThrowError(
          DataSignError
        );
      });
    });

    describe('signTx', () => {
      let hexTxBody: string;
      beforeAll(async () => {
        const txInternals = await wallet.initializeTx(simpleTxProps);
        const finalizedTx = await wallet.finalizeTx(txInternals);
        hexTxBody = Buffer.from(coreToCsl.tx(finalizedTx).body().to_bytes()).toString('hex');
      });

      test('resolves true', async () => {
        confirmationCallback.mockResolvedValueOnce(true);
        await expect(api.signTx(hexTxBody)).resolves.not.toThrow();
      });

      test('resolves false', async () => {
        confirmationCallback.mockResolvedValueOnce(false);
        await expect(api.signTx(hexTxBody)).rejects.toThrowError(TxSignError);
      });

      test('rejects', async () => {
        confirmationCallback.mockRejectedValue(1);
        await expect(api.signTx(hexTxBody)).rejects.toThrowError(TxSignError);
      });
    });

    describe('submitTx', () => {
      let cslTx: string;
      let txInternals: InitializeTxResult;
      let finalizedTx: Cardano.NewTxAlonzo<Cardano.NewTxBodyAlonzo>;

      beforeAll(async () => {
        txInternals = await wallet.initializeTx(simpleTxProps);
        finalizedTx = await wallet.finalizeTx(txInternals);

        cslTx = Buffer.from(coreToCsl.tx(finalizedTx).to_bytes()).toString('hex');
      });

      test('resolves true', async () => {
        confirmationCallback.mockResolvedValueOnce(true);
        await expect(api.submitTx(cslTx)).resolves.toBe(finalizedTx.id);
      });

      test('resolves false', async () => {
        confirmationCallback.mockResolvedValueOnce(false);
        await expect(api.submitTx(cslTx)).rejects.toThrowError(TxSendError);
      });

      test('rejects', async () => {
        confirmationCallback.mockRejectedValue(1);
        await expect(api.submitTx(cslTx)).rejects.toThrowError(TxSendError);
      });
    });
  });
});
