/* eslint-disable @typescript-eslint/no-explicit-any */
import { CSL, Cardano, coreToCsl } from '@cardano-sdk/core';
import { InitializeTxProps, KeyManagement, SingleAddressWallet, cip30 } from '../../src';
import { TxSignError, WalletApi, createUiWallet } from '@cardano-sdk/cip30';
import { createWallet } from './util';
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
      mappedWallet = cip30.createWalletApi(wallet);
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
      expect(async () => await mappedWallet.submitTx(Buffer.from(cslTx).toString('hex'))).not.toThrow();
    });

    test.todo('errorStates');
  });

  // almost as good as running in browser
  describe('initialize', () => {
    let cleanup: Function;
    beforeAll(() => {
      let onMessageHandler: any;
      const chromeRuntime = (global as any).chrome.runtime;
      chromeRuntime.onMessage.addListener.mockImplementation((handler: any) => (onMessageHandler = handler));
      chromeRuntime.sendMessage.mockImplementation((message: any, callback: any) =>
        onMessageHandler(message, null, callback)
      );
      cleanup = cip30.initialize(wallet);
    });
    afterAll(() => cleanup());

    it('works using browser runtime messages', async () => {
      const uiWallet = createUiWallet();
      const utxos = await uiWallet.getUtxos();
      expect(() => coreToCsl.utxo(utxos!)).not.toThrow();
    });

    it('rejects on error', async () => {
      const txInternals = await wallet.initializeTx(simpleTxProps);
      const finalizedTx = await wallet.finalizeTx(txInternals);
      const hexTxBody = Buffer.from(coreToCsl.tx(finalizedTx).body().to_bytes()).toString('hex');

      wallet.keyAgent.signTransaction = jest.fn().mockRejectedValueOnce(new KeyManagement.errors.AuthenticationError());
      const uiWallet = createUiWallet();
      await expect(() => uiWallet.signTx(hexTxBody)).rejects.toThrowError(TxSignError);
    });
  });
});
