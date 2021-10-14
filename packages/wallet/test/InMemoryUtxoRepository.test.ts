/* eslint-disable promise/param-names */
import { roundRobinRandomImprove, InputSelector } from '@cardano-sdk/cip2';
import { loadCardanoSerializationLib, CardanoSerializationLib, CSL, Ogmios, Cardano } from '@cardano-sdk/core';
import { flushPromises, SelectionConstraints } from '@cardano-sdk/util-dev';
import { providerStub, delegate, rewards, ProviderStub, utxo, delegationAndRewards } from './ProviderStub';
import {
  InMemoryUtxoRepository,
  KeyManagement,
  TransactionTrackerEvent,
  UtxoRepository,
  UtxoRepositoryEvent,
  UtxoRepositoryFields
} from '../src';
import { MockTransactionTracker } from './mockTransactionTracker';
import { ogmiosToCsl } from '@cardano-sdk/core/src/Ogmios';
import { TxIn, TxOut } from '@cardano-ogmios/schema';
import { TransactionError, TransactionFailure } from '../src/TransactionError';

const addresses = [
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
];

describe('InMemoryUtxoRepository', () => {
  let utxoRepository: UtxoRepository;
  let provider: ProviderStub;
  let inputSelector: InputSelector;
  let csl: CardanoSerializationLib;
  let keyManager: KeyManagement.KeyManager;
  let outputs: Set<CSL.TransactionOutput>;
  let txTracker: MockTransactionTracker;

  beforeEach(async () => {
    provider = providerStub();
    csl = await loadCardanoSerializationLib();
    inputSelector = roundRobinRandomImprove(csl);
    keyManager = KeyManagement.createInMemoryKeyManager({
      csl,
      mnemonicWords: KeyManagement.util.generateMnemonicWords(),
      networkId: 0,
      password: '123'
    });
    outputs = new Set([
      Ogmios.ogmiosToCsl(csl).txOut({
        address: addresses[0],
        value: { coins: 4_000_000 }
      }),
      Ogmios.ogmiosToCsl(csl).txOut({
        address: addresses[0],
        value: { coins: 2_000_000 }
      })
    ]);
    txTracker = new MockTransactionTracker();
    utxoRepository = new InMemoryUtxoRepository({
      csl,
      provider,
      keyManager,
      inputSelector,
      txTracker
    });
  });

  test('constructed state', async () => {
    await expect(utxoRepository.allUtxos.length).toBe(0);
    await expect(utxoRepository.allRewards).toBe(null);
    await expect(utxoRepository.delegation).toBe(null);
  });

  test('sync', async () => {
    const syncedHandler = jest.fn();
    utxoRepository.on(UtxoRepositoryEvent.Changed, syncedHandler);
    await utxoRepository.sync();
    const expectedFields: UtxoRepositoryFields = {
      allUtxos: utxo,
      availableUtxos: utxo,
      allRewards: rewards,
      availableRewards: rewards,
      delegation: delegate
    };
    expect(utxoRepository).toMatchObject(expectedFields);
    expect(syncedHandler).toBeCalledTimes(1);
    expect(syncedHandler).toBeCalledWith(expectedFields);
    // await expect(utxoRepository.allUtxos.length).toBe(3);
    // await expect(utxoRepository.allRewards).toBe(rewards);
    // await expect(utxoRepository.delegation).toBe(delegate);
    const identicalUtxo = [{ ...utxo[1][0] }, { ...utxo[1][1] }] as const; // clone UTxO
    provider.utxoDelegationAndRewards.mockResolvedValueOnce({
      utxo: [utxo[0], identicalUtxo],
      delegationAndRewards
    });
    await utxoRepository.sync();
    await expect(utxoRepository.allUtxos.length).toBe(2);
    // Verify we're not replacing the object with an identical one in the UTxO set
    await expect(utxoRepository.allUtxos).not.toContain(identicalUtxo);
    await expect(utxoRepository.allUtxos).toContain(utxo[1]);
    expect(syncedHandler).toBeCalledTimes(2);
  });

  describe('selectInputs', () => {
    it('can be called without explicitly syncing', async () => {
      const result = await utxoRepository.selectInputs(outputs, SelectionConstraints.NO_CONSTRAINTS);
      await expect(utxoRepository.allUtxos.length).toBe(3);
      await expect(utxoRepository.allRewards).toBe(rewards);
      await expect(utxoRepository.delegation).toBe(delegate);
      await expect(result.selection.inputs.size).toBeGreaterThan(0);
      await expect(result.selection.outputs).toBe(outputs);
      await expect(result.selection.change.size).toBe(2);
    });
  });

  describe('availableUtxos and availableRewards', () => {
    let transactionUtxo: [TxIn, TxOut];
    let transaction: CSL.Transaction;
    let numUtxoPreTransaction: number;
    let rewardsPreTransaction: bigint;
    let onOutOfSync: jest.Mock;
    let completeConfirmation: Function;
    const transactionWithdrawal = 1n;

    const trackTransaction = async (confirmed: Promise<void>) => {
      const syncedHandler = jest.fn();
      utxoRepository.on(UtxoRepositoryEvent.Changed, syncedHandler);
      await txTracker.emit(TransactionTrackerEvent.NewTransaction, {
        transaction,
        confirmed
      });
      // transaction not yet confirmed
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length - 1);
      expect(utxoRepository.availableUtxos).not.toContain(transactionUtxo);
      expect(syncedHandler).toBeCalledTimes(1);
      expect(syncedHandler).toBeCalledWith({
        allUtxos: utxo,
        availableUtxos: utxo.slice(1),
        allRewards: rewards,
        availableRewards: rewards - transactionWithdrawal,
        delegation: delegate
      } as UtxoRepositoryFields);
    };

    beforeEach(async () => {
      transactionUtxo = utxo[0];
      transaction = {
        body: () => ({
          inputs: () => ({
            len: () => 1,
            get: () => ogmiosToCsl(csl).txIn(transactionUtxo[0])
          }),
          withdrawals: () => ({
            keys: () => ({
              len: () => 1,
              get: () =>
                csl.RewardAddress.new(
                  Cardano.NetworkId.testnet,
                  csl.StakeCredential.from_keyhash(keyManager.stakeKey.hash())
                )
            }),
            len: () => 1,
            get: () => csl.BigNum.from_str(transactionWithdrawal.toString())
          })
        })
      } as unknown as CSL.Transaction;
      await utxoRepository.sync();
      numUtxoPreTransaction = utxoRepository.allUtxos.length;
      rewardsPreTransaction = utxoRepository.allRewards!;
      onOutOfSync = jest.fn();
      utxoRepository.on(UtxoRepositoryEvent.OutOfSync, onOutOfSync);
    });

    it('preconditions', () => {
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length);
      expect(utxoRepository.availableUtxos).toContain(transactionUtxo);
      expect(utxoRepository.availableRewards).toBe(rewardsPreTransaction);
    });

    describe('sync success', () => {
      beforeEach(() => {
        // Simulate spent utxo and rewards
        expect(provider.utxoDelegationAndRewards).toBeCalledTimes(1);
        provider.utxoDelegationAndRewards.mockResolvedValueOnce({
          utxo: utxo.slice(1),
          delegationAndRewards: {
            ...delegationAndRewards,
            rewards: rewards - transactionWithdrawal
          }
        });
      });

      it('transaction confirmed', async () => {
        await trackTransaction(new Promise<void>((resolve) => (completeConfirmation = resolve)));
      });

      it('transaction confirmation failed', async () => {
        // setup for transaction to timeout
        await trackTransaction(
          new Promise<void>(
            (_, reject) => (completeConfirmation = () => reject(new TransactionError(TransactionFailure.Timeout)))
          )
        );
      });

      afterEach(async () => {
        // Review: is it ok to reuse code by utilizing afterEach, or should we only use it for test cleanup?
        // transaction confirmed or rejected, based on 'completeConfirmation' function set by test
        await completeConfirmation!();
        await flushPromises();
        // Assert values from provider sync
        expect(provider.utxoDelegationAndRewards).toBeCalledTimes(2);
        expect(utxoRepository.availableUtxos).toHaveLength(numUtxoPreTransaction - 1);
        expect(utxoRepository.availableUtxos).not.toContain(transactionUtxo);
        expect(utxoRepository.availableRewards).toBe(rewardsPreTransaction - transactionWithdrawal);
        expect(onOutOfSync).not.toBeCalled();
      });
    });

    it('emits OutOfSync on sync failure', async () => {
      provider.utxoDelegationAndRewards.mockRejectedValueOnce(new Error('any error'));

      const confirmed = new Promise<void>((resolve) => (completeConfirmation = resolve));
      await trackTransaction(confirmed);

      // transaction confirmed
      await completeConfirmation!();
      await flushPromises();
      expect(utxoRepository.availableUtxos).toHaveLength(numUtxoPreTransaction);
      expect(utxoRepository.availableUtxos).toContain(transactionUtxo);
      expect(utxoRepository.allRewards).toBe(rewardsPreTransaction);
      expect(onOutOfSync).toBeCalledTimes(1);
    });

    afterEach(() => {
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length);
      expect(utxoRepository.allRewards).toBe(utxoRepository.availableRewards);
    });
  });
});
