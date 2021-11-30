/* eslint-disable max-len */
import * as mocks from './mocks';
import { AssetId, createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet } from '../src';
import { firstValueFrom, skip } from 'rxjs';

describe('SingleAddressWallet', () => {
  const name = 'Test Wallet';
  const address = mocks.queryTransactionsResult[0].body.inputs[0].address;
  const rewardAccount = mocks.rewardAccount;
  let keyManager: KeyManagement.KeyManager;
  let walletProvider: mocks.ProviderStub;
  let assetProvider: mocks.MockAssetProvider;
  let wallet: SingleAddressWallet;

  beforeEach(async () => {
    keyManager = KeyManagement.createInMemoryKeyManager({
      mnemonicWords: KeyManagement.util.generateMnemonicWords(),
      networkId: Cardano.NetworkId.testnet,
      password: '123'
    });
    walletProvider = mocks.mockWalletProvider();
    assetProvider = mocks.mockAssetProvider();
    const stakePoolSearchProvider = createStubStakePoolSearchProvider();
    keyManager.deriveAddress = jest.fn().mockReturnValue({
      address,
      rewardAccount
    });
    wallet = new SingleAddressWallet({ name }, { assetProvider, keyManager, stakePoolSearchProvider, walletProvider });
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
        Cardano.util.coalesceValueQuantities(mocks.utxo.map((utxo) => utxo[1].value)).coins
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
    it('"networkInfo$"', async () => {
      await firstValueFrom(wallet.networkInfo$);
      expect(wallet.networkInfo$.value?.currentEpoch).toEqual(mocks.currentEpoch);
    });
    it('"protocolParameters$"', async () => {
      await firstValueFrom(wallet.protocolParameters$);
      expect(wallet.protocolParameters$.value).toEqual(mocks.protocolParameters);
    });
    it('"genesisParameters$"', async () => {
      await firstValueFrom(wallet.genesisParameters$);
      expect(wallet.genesisParameters$.value).toEqual(mocks.genesisParameters);
    });
    it('"delegation"', async () => {
      const rewardsHistory = await firstValueFrom(wallet.delegation.rewardsHistory$);
      expect(rewardsHistory.all).toEqual(mocks.rewardsHistory);
      const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
      expect(rewardAccounts).toHaveLength(1);
      expect(rewardAccounts[0].address).toBe(rewardAccount);
      expect(rewardAccounts[0].delegatee).toBeUndefined();
      expect(rewardAccounts[0].rewardBalance.total).toBe(mocks.rewards);
    });
    it('"addresses$"', () => {
      expect(wallet.addresses$.value[0].address).toEqual(address);
      expect(wallet.addresses$.value[0].rewardAccount).toEqual(rewardAccount);
    });
    it('"assets$"', async () => {
      expect(await firstValueFrom(wallet.assets$)).toEqual(new Map([[AssetId.TSLA, mocks.asset]]));
    });
  });

  describe('creating transactions', () => {
    const props = {
      outputs: new Set([
        {
          address: Cardano.Address(
            'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
          ),
          value: { coins: 11_111_111n }
        }
      ])
    };

    it('initializeTx', async () => {
      const { body, hash } = await wallet.initializeTx(props);
      expect(body.outputs).toHaveLength(props.outputs.size + 1 /* change output */);
      expect(typeof hash).toBe('string');
    });

    it('finalizeTx', async () => {
      const txInternals = await wallet.initializeTx(props);
      const tx = await wallet.finalizeTx(txInternals);
      expect(tx.body).toBe(txInternals.body);
      expect(tx.id).toBe(txInternals.hash);
      expect(tx.witness.signatures.size).toBe(1);
    });

    it('submitTx', async () => {
      const tx = await wallet.finalizeTx(await wallet.initializeTx(props));
      const txSubmitting = firstValueFrom(wallet.transactions.outgoing.submitting$);
      const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
      const txInFlight = firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(skip(1)));
      await wallet.submitTx(tx);
      expect(walletProvider.submitTx).toBeCalledTimes(1);
      expect(await txSubmitting).toBe(tx);
      expect(await txPending).toBe(tx);
      expect(await txInFlight).toEqual([tx]);
    });
  });

  it('sync() calls wallet provider functions until shutdown()', () => {
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(1);
    wallet.sync();
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(2);
    wallet.shutdown();
    wallet.sync();
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(2);
  });
});
