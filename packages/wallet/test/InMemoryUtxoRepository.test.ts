/* eslint-disable unicorn/consistent-function-scoping */
/* eslint-disable promise/param-names */
import { CSL, Cardano, coreToCsl } from '@cardano-sdk/core';
import {
  InMemoryUtxoRepository,
  KeyManagement,
  TransactionTrackerEvent,
  UtxoRepository,
  UtxoRepositoryEvent,
  UtxoRepositoryFields
} from '../src';
import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import {
  MockTransactionTracker,
  ProviderStub,
  delegate,
  delegationAndRewards,
  providerStub,
  rewards,
  utxo
} from './mocks';
import { SelectionConstraints, flushPromises } from '@cardano-sdk/util-dev';
import { TransactionError, TransactionFailure } from '../src/TransactionError';

const addresses = [
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
];

describe('InMemoryUtxoRepository', () => {
  let utxoRepository: UtxoRepository;
  let provider: ProviderStub;
  let inputSelector: InputSelector;
  let keyManager: KeyManagement.KeyManager;
  let outputs: Set<CSL.TransactionOutput>;
  let txTracker: MockTransactionTracker;

  beforeEach(async () => {
    provider = providerStub();
    inputSelector = roundRobinRandomImprove();
    keyManager = KeyManagement.createInMemoryKeyManager({
      mnemonicWords: KeyManagement.util.generateMnemonicWords(),
      networkId: 0,
      password: '123'
    });
    outputs = new Set([
      coreToCsl.txOut({
        address: addresses[0],
        value: { coins: 4_000_000n }
      }),
      coreToCsl.txOut({
        address: addresses[0],
        value: { coins: 2_000_000n }
      })
    ]);
    txTracker = new MockTransactionTracker();
    utxoRepository = new InMemoryUtxoRepository({
      inputSelector,
      keyManager,
      provider,
      txTracker
    });
  });

  test('constructed state', async () => {
    expect(utxoRepository.allUtxos.length).toBe(0);
    expect(utxoRepository.allRewards).toBe(null);
    expect(utxoRepository.delegation).toBe(null);
  });

  test('sync', async () => {
    const syncedHandler = jest.fn();
    utxoRepository.on(UtxoRepositoryEvent.Changed, syncedHandler);
    await utxoRepository.sync();
    const expectedFields: UtxoRepositoryFields = {
      allRewards: rewards,
      allUtxos: utxo,
      availableRewards: rewards,
      availableUtxos: utxo,
      delegation: delegate
    };
    expect(utxoRepository).toMatchObject(expectedFields);
    expect(syncedHandler).toBeCalledTimes(1);
    expect(syncedHandler).toBeCalledWith(expectedFields);
    const identicalUtxo = [{ ...utxo[1][0] }, { ...utxo[1][1] }] as const; // clone UTxO
    provider.utxoDelegationAndRewards.mockResolvedValueOnce({
      delegationAndRewards,
      utxo: [utxo[0], identicalUtxo]
    });
    await utxoRepository.sync();
    expect(utxoRepository.allUtxos.length).toBe(2);
    // Verify we're not replacing the object with an identical one in the UTxO set
    expect(utxoRepository.allUtxos).not.toContain(identicalUtxo);
    expect(utxoRepository.allUtxos).toContain(utxo[1]);
    expect(syncedHandler).toBeCalledTimes(2);
  });

  describe('selectInputs', () => {
    it('can be called without explicitly syncing', async () => {
      const result = await utxoRepository.selectInputs(outputs, SelectionConstraints.NO_CONSTRAINTS);
      expect(utxoRepository.allUtxos.length).toBe(3);
      expect(utxoRepository.allRewards).toBe(rewards);
      expect(utxoRepository.delegation).toBe(delegate);
      expect(result.selection.inputs.size).toBeGreaterThan(0);
      expect(result.selection.outputs).toBe(outputs);
      expect(result.selection.change.size).toBe(2);
    });
  });

  describe('availableUtxos and availableRewards', () => {
    let transactionUtxo: Cardano.Utxo;
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
        confirmed,
        transaction
      });
      // transaction not yet confirmed
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length - 1);
      expect(utxoRepository.availableUtxos).not.toContain(transactionUtxo);
      expect(syncedHandler).toBeCalledTimes(1);
      expect(syncedHandler).toBeCalledWith({
        allRewards: rewards,
        allUtxos: utxo,
        availableRewards: rewards - transactionWithdrawal,
        availableUtxos: utxo.slice(1),
        delegation: delegate
      } as UtxoRepositoryFields);
    };

    const assertThereAreNoPendingTransactionsOrRewards = () => {
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length);
      expect(utxoRepository.allRewards).toBe(utxoRepository.availableRewards);
    };

    beforeEach(async () => {
      transactionUtxo = utxo[0];
      transaction = {
        body: () => ({
          inputs: () => ({
            get: () => coreToCsl.txIn(transactionUtxo[0]),
            len: () => 1
          }),
          withdrawals: () => ({
            get: () => CSL.BigNum.from_str(transactionWithdrawal.toString()),
            keys: () => ({
              get: () =>
                CSL.RewardAddress.new(
                  Cardano.NetworkId.testnet,
                  CSL.StakeCredential.from_keyhash(keyManager.stakeKey.hash())
                ),
              len: () => 1
            }),
            len: () => 1
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
          delegationAndRewards: {
            ...delegationAndRewards,
            rewards: rewards - transactionWithdrawal
          },
          utxo: utxo.slice(1)
        });
      });

      const confirmTxAndAssertUtxoRepositorySynced = async () => {
        await completeConfirmation!();
        await flushPromises();
        // Assert values from provider sync
        expect(provider.utxoDelegationAndRewards).toBeCalledTimes(2);
        expect(utxoRepository.availableUtxos).toHaveLength(numUtxoPreTransaction - 1);
        expect(utxoRepository.availableUtxos).not.toContain(transactionUtxo);
        expect(utxoRepository.availableRewards).toBe(rewardsPreTransaction - transactionWithdrawal);
        expect(onOutOfSync).not.toBeCalled();
      };

      it('transaction confirmed', async () => {
        await trackTransaction(new Promise<void>((resolve) => (completeConfirmation = resolve)));
        await confirmTxAndAssertUtxoRepositorySynced();
        assertThereAreNoPendingTransactionsOrRewards();
      });

      it('transaction confirmation failed', async () => {
        // setup for transaction to timeout
        await trackTransaction(
          new Promise<void>(
            (_, reject) => (completeConfirmation = () => reject(new TransactionError(TransactionFailure.Timeout)))
          )
        );
        await confirmTxAndAssertUtxoRepositorySynced();
        assertThereAreNoPendingTransactionsOrRewards();
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
      assertThereAreNoPendingTransactionsOrRewards();
    });
  });
});
