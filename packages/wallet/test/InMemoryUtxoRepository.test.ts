/* eslint-disable promise/param-names */
import { roundRobinRandomImprove, InputSelector } from '@cardano-sdk/cip2';
import { loadCardanoSerializationLib, CardanoSerializationLib, CSL, Ogmios } from '@cardano-sdk/core';
import { flushPromises, SelectionConstraints } from '@cardano-sdk/util-dev';
import { providerStub, delegate, rewards, ProviderStub, utxo, delegationAndRewards } from './ProviderStub';
import { InMemoryUtxoRepository, KeyManagement, UtxoRepository } from '../src';
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
  let outputs: Set<CSL.TransactionOutput>;
  let txTracker: MockTransactionTracker;

  beforeEach(async () => {
    provider = providerStub();
    csl = await loadCardanoSerializationLib();
    inputSelector = roundRobinRandomImprove(csl);
    const keyManager = KeyManagement.createInMemoryKeyManager({
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
    utxoRepository = new InMemoryUtxoRepository({ csl, provider, keyManager, inputSelector, txTracker });
  });

  test('constructed state', async () => {
    await expect(utxoRepository.allUtxos.length).toBe(0);
    await expect(utxoRepository.rewards).toBe(null);
    await expect(utxoRepository.delegation).toBe(null);
  });

  test('sync', async () => {
    await utxoRepository.sync();
    await expect(utxoRepository.allUtxos.length).toBe(3);
    await expect(utxoRepository.rewards).toBe(rewards);
    await expect(utxoRepository.delegation).toBe(delegate);
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
  });

  describe('selectInputs', () => {
    it('can be called without explicitly syncing', async () => {
      const result = await utxoRepository.selectInputs(outputs, SelectionConstraints.NO_CONSTRAINTS);
      await expect(utxoRepository.allUtxos.length).toBe(3);
      await expect(utxoRepository.rewards).toBe(rewards);
      await expect(utxoRepository.delegation).toBe(delegate);
      await expect(result.selection.inputs.size).toBeGreaterThan(0);
      await expect(result.selection.outputs).toBe(outputs);
      await expect(result.selection.change.size).toBe(2);
    });
  });

  describe('availableUtxos', () => {
    let transactionUtxo: [TxIn, TxOut];
    let transaction: CSL.Transaction;
    let numUtxoPreTransaction: number;
    let onTransactionUntracked: jest.Mock;

    const trackTransaction = async (confirmed: Promise<void>) => {
      await txTracker.emit('transaction', {
        transaction,
        confirmed
      });
      // transaction not yet confirmed
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length - 1);
      expect(utxoRepository.availableUtxos).not.toContain(transactionUtxo);
    };

    beforeEach(async () => {
      transactionUtxo = utxo[0];
      transaction = {
        body: () => ({
          inputs: () => ({
            len: () => 1,
            get: () => ogmiosToCsl(csl).txIn(transactionUtxo[0])
          })
        })
      } as unknown as CSL.Transaction;
      await utxoRepository.sync();
      numUtxoPreTransaction = utxoRepository.allUtxos.length;
      onTransactionUntracked = jest.fn();
      utxoRepository.on('transactionUntracked', onTransactionUntracked);
    });

    it('preconditions', () => {
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length);
      expect(utxoRepository.availableUtxos).toContain(transactionUtxo);
    });

    it('transaction confirmed', async () => {
      let completeConfirmation: Function;
      const confirmed = new Promise<void>((resolve) => (completeConfirmation = resolve));
      await trackTransaction(confirmed);

      // transaction confirmed
      await completeConfirmation!();
      expect(utxoRepository.availableUtxos).toHaveLength(numUtxoPreTransaction - 1);
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length);
      expect(utxoRepository.availableUtxos).not.toContain(transactionUtxo);
    });

    it('transaction timed out', async () => {
      // setup for transaction to timeout
      let completeConfirmation: Function;
      const confirmed = new Promise<void>(
        (_, reject) => (completeConfirmation = () => reject(new TransactionError(TransactionFailure.Timeout)))
      );
      await trackTransaction(confirmed);

      // transaction rejected
      await completeConfirmation!();
      expect(onTransactionUntracked).not.toBeCalled();
      expect(utxoRepository.availableUtxos).toHaveLength(numUtxoPreTransaction);
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length);
      expect(utxoRepository.availableUtxos).toContain(transactionUtxo);
    });

    it('emits transactionUntracked on any other transaction tracker error', async () => {
      // setup for transaction to timeout
      let completeConfirmation: Function;
      const confirmed = new Promise<void>(
        (_, reject) => (completeConfirmation = () => reject(new TransactionError(TransactionFailure.CannotTrack)))
      );
      await trackTransaction(confirmed);

      // Assuming UTxO is still available, SDK user should call TransactionTracker.trackTransaction to lock it again.
      await completeConfirmation!();
      await flushPromises();
      expect(onTransactionUntracked).toBeCalledTimes(1);
      expect(onTransactionUntracked).toBeCalledWith(transaction);
      expect(utxoRepository.availableUtxos).toHaveLength(numUtxoPreTransaction);
      expect(utxoRepository.availableUtxos).toHaveLength(utxoRepository.allUtxos.length);
      expect(utxoRepository.availableUtxos).toContain(transactionUtxo);
    });
  });
});
