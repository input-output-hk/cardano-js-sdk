/* eslint-disable @typescript-eslint/no-explicit-any, sonarjs/no-duplicate-string */
import { CSL, Cardano, coreToCsl } from '@cardano-sdk/core';
import { DataSignError, TxSendError, TxSignError, WalletApi } from '@cardano-sdk/cip30';
import { InitializeTxProps, InitializeTxResult, KeyManagement, SingleAddressWallet, cip30 } from '../../src';
import { createWallet } from './util';
import { createWebExtensionWalletClient } from '@cardano-sdk/cip30/dist/WebExtension';
import { firstValueFrom } from 'rxjs';
import { networkId } from '../mocks';
import { waitForWalletStateSettle } from '../util';

describe('cip30', () => {
  let wallet: SingleAddressWallet;

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
  });

  afterAll(() => {
    wallet.shutdown();
  });

  describe('createWalletApi', () => {
    let mappedWallet: WalletApi;

    beforeAll(async () => {
      mappedWallet = cip30.createWalletApi(wallet, () => Promise.resolve(true));
      await waitForWalletStateSettle(wallet);
    });

    test('api.getNetworkId', async () => {
      const cip30NetworkId = await mappedWallet.getNetworkId();
      expect(cip30NetworkId).toEqual(networkId);
    });

    test('api.getUtxos', async () => {
      const utxos = await mappedWallet.getUtxos();
      expect(() => coreToCsl.utxo(utxos!)).not.toThrow();
    });

    test('api.getBalance', async () => {
      const balanceCborBytes = Buffer.from(await mappedWallet.getBalance(), 'hex');
      expect(() => CSL.Value.from_bytes(balanceCborBytes)).not.toThrow();
    });

    test('api.getUsedAddresses', async () => {
      const cipUsedAddressess = await mappedWallet.getUsedAddresses();
      const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
      expect(cipUsedAddressess).toEqual([walletAddress]);
    });

    test('api.getUnusedAddresses', async () => {
      const cipUsedAddressess = await mappedWallet.getUnusedAddresses();
      expect(cipUsedAddressess).toEqual([]);
    });

    test('api.getChangeAddress', async () => {
      const cipChangeAddress = await mappedWallet.getChangeAddress();
      const [{ address: walletAddress }] = await firstValueFrom(wallet.addresses$);
      expect(cipChangeAddress).toEqual(walletAddress);
    });

    test('api.getRewardAddresses', async () => {
      const cipRewardAddresses = await mappedWallet.getRewardAddresses();
      const [{ rewardAccount: walletRewardAccount }] = await firstValueFrom(wallet.addresses$);
      expect(cipRewardAddresses).toEqual([walletRewardAccount]);
    });

    test('api.signTx', async () => {
      const txInternals = await wallet.initializeTx(simpleTxProps);
      const finalizedTx = await wallet.finalizeTx(txInternals);
      const hexTxBody = Buffer.from(coreToCsl.tx(finalizedTx).body().to_bytes()).toString('hex');

      const cip30witnessSet = await mappedWallet.signTx(hexTxBody);
      const signatures = Buffer.from(cip30witnessSet, 'hex');
      expect(() => CSL.TransactionWitnessSet.from_bytes(signatures)).not.toThrow();
    });

    test('api.signData', async () => {
      const [{ address }] = await firstValueFrom(wallet.addresses$);
      const cip30dataSignature = await mappedWallet.signData(address, Cardano.util.HexBlob('abc123').toString());
      expect(typeof cip30dataSignature.key).toBe('string');
      expect(typeof cip30dataSignature.signature).toBe('string');
    });

    test('api.submitTx', async () => {
      const txInternals = await wallet.initializeTx(simpleTxProps);
      const finalizedTx = await wallet.finalizeTx(txInternals);

      const cslTx = coreToCsl.tx(finalizedTx).to_bytes();
      await expect(mappedWallet.submitTx(Buffer.from(cslTx).toString('hex'))).resolves.not.toThrow();
    });

    test.todo('errorStates');
  });

  describe('confirmation callbacks', () => {
    let api: WalletApi;
    const confirmationCallback: jest.Mock = jest.fn();
    beforeAll(() => {
      let onMessageHandler: any;
      const chromeRuntime = (global as any).chrome.runtime;
      chromeRuntime.onMessage.addListener.mockImplementation((handler: any) => (onMessageHandler = handler));
      chromeRuntime.sendMessage.mockImplementation((_: any, message: any, callback: any) =>
        onMessageHandler(message, null, callback)
      );
      cip30.initialize(wallet, confirmationCallback);
      api = createWebExtensionWalletClient({ walletExtensionId: 'someid', walletName: wallet.name });
    });

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

  // almost as good as running in browser
  describe('initialize', () => {
    let cleanup: Function;
    beforeAll(() => {
      let onMessageHandler: any;
      const chromeRuntime = (global as any).chrome.runtime;
      chromeRuntime.onMessage.addListener.mockImplementation((handler: any) => (onMessageHandler = handler));
      chromeRuntime.sendMessage.mockImplementation((_: any, message: any, callback: any) =>
        onMessageHandler(message, null, callback)
      );
      cleanup = cip30.initialize(wallet, () => Promise.resolve(true));
    });
    afterAll(() => cleanup());

    it('works using browser runtime messages', async () => {
      const api = createWebExtensionWalletClient({ walletExtensionId: 'someid', walletName: wallet.name });
      const utxos = await api.getUtxos();
      expect(() => coreToCsl.utxo(utxos!)).not.toThrow();
    });

    it('rejects on error', async () => {
      const txInternals = await wallet.initializeTx(simpleTxProps);
      const finalizedTx = await wallet.finalizeTx(txInternals);
      const hexTxBody = Buffer.from(coreToCsl.tx(finalizedTx).body().to_bytes()).toString('hex');

      wallet.keyAgent.signTransaction = jest.fn().mockRejectedValueOnce(new KeyManagement.errors.AuthenticationError());
      const api = createWebExtensionWalletClient({ walletExtensionId: 'someid', walletName: wallet.name });
      await expect(api.signTx(hexTxBody)).rejects.toThrowError(TxSignError);
    });
  });
});
