/* eslint-disable max-len */
import * as mocks from './mocks';
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet } from '../src';
import { coalesceValueQuantities } from '@cardano-sdk/core/src/Cardano/util';
import { firstValueFrom, skip } from 'rxjs';

describe('SingleAddressWallet', () => {
  const name = 'Test Wallet';
  const address = mocks.queryTransactionsResult[0].body.inputs[0].address;
  let keyManager: KeyManagement.KeyManager;
  let walletProvider: mocks.ProviderStub;
  let wallet: SingleAddressWallet;

  beforeEach(async () => {
    keyManager = KeyManagement.createInMemoryKeyManager({
      mnemonicWords: KeyManagement.util.generateMnemonicWords(),
      networkId: Cardano.NetworkId.testnet,
      password: '123'
    });
    walletProvider = mocks.providerStub();
    keyManager.deriveAddress = jest.fn().mockReturnValue(address);
    wallet = new SingleAddressWallet({ name }, { keyManager, walletProvider });
  });

  afterEach(() => wallet.shutdown());

  describe('has property', () => {
    it('"name"', async () => {
      expect(wallet.name).toBe(name);
    });
    it('"utxo"', async () => {
      await firstValueFrom(wallet.utxo.available$);
      await firstValueFrom(wallet.utxo.total$);
      expect(wallet.utxo.available$.value).toEqual(mocks.utxo);
      expect(wallet.utxo.total$.value).toEqual(mocks.utxo);
    });
    it('"balance"', async () => {
      await firstValueFrom(wallet.balance.available$);
      await firstValueFrom(wallet.balance.total$);
      expect(wallet.balance.available$.value?.coins).toEqual(
        coalesceValueQuantities(mocks.utxo.map((utxo) => utxo[1].value)).coins
      );
      expect(wallet.balance.total$.value?.rewards).toBe(mocks.rewards);
    });
    it('"transactions"', async () => {
      await firstValueFrom(wallet.transactions.history.all$);
      expect(wallet.transactions.history.all$.value?.length).toBeGreaterThan(0);
    });
    it('"tip$"', async () => {
      await firstValueFrom(wallet.tip$);
      expect(wallet.tip$.value).toEqual(mocks.ledgerTip);
    });
    it('"protocolParameters$"', async () => {
      await firstValueFrom(wallet.protocolParameters$);
      expect(wallet.protocolParameters$.value).toEqual(mocks.protocolParameters);
    });
    it('"addresses"', () => {
      expect(wallet.addresses).toEqual([address]);
    });
  });

  describe('creating transactions', () => {
    const props = {
      outputs: new Set([
        {
          address:
            'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w',
          value: { coins: 11_111_111n }
        }
      ])
    };

    it('initializeTx', async () => {
      const txInternals = await wallet.initializeTx(props);
      expect(txInternals.body).toBeInstanceOf(CSL.TransactionBody);
      expect(txInternals.hash).toBeInstanceOf(CSL.TransactionHash);
    });

    it('finalizeTx', async () => {
      const { body, hash } = await wallet.initializeTx(props);
      const tx = await wallet.finalizeTx({ body, hash });
      expect(tx.body().outputs().len()).toBe(2);
      expect(tx.body().inputs().len()).toBeGreaterThan(0);
    });

    it('submitTx', async () => {
      const tx = await wallet.finalizeTx(await wallet.initializeTx(props));
      const txSubmitting = firstValueFrom(wallet.transactions.outgoing.submitting$);
      const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
      const txInFlight = firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(skip(1)));
      await wallet.submitTx(tx);
      expect(walletProvider.submitTx).toBeCalledTimes(1);
      expect(walletProvider.submitTx).toBeCalledWith(tx);
      expect(await txSubmitting).toBe(tx);
      expect(await txPending).toBe(tx);
      expect(await txInFlight).toEqual([tx]);
    });
  });

  it('sync() calls wallet provider functions until shutdown()', () => {
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(1);
    expect(walletProvider.currentWalletProtocolParameters).toHaveBeenCalledTimes(1);
    expect(walletProvider.queryTransactionsByAddresses).toHaveBeenCalledTimes(1);
    expect(walletProvider.utxoDelegationAndRewards).toHaveBeenCalledTimes(2); // one call for utxo, one for rewards
    wallet.sync();
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(2);
    expect(walletProvider.currentWalletProtocolParameters).toHaveBeenCalledTimes(2);
    expect(walletProvider.queryTransactionsByAddresses).toHaveBeenCalledTimes(2);
    expect(walletProvider.utxoDelegationAndRewards).toHaveBeenCalledTimes(4);
    wallet.shutdown();
    wallet.sync();
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(2);
    expect(walletProvider.currentWalletProtocolParameters).toHaveBeenCalledTimes(2);
    expect(walletProvider.queryTransactionsByAddresses).toHaveBeenCalledTimes(2);
    expect(walletProvider.utxoDelegationAndRewards).toHaveBeenCalledTimes(4);
  });
});
