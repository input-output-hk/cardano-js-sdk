/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
/* eslint-disable prettier/prettier */
import { Cardano, WalletProvider } from '@cardano-sdk/core';
import {
  FailedTx,
  TransactionDirection,
  TransactionFailure,
  createAddressTransactionsProvider,
  createTransactionsTracker
} from '../../src';
import { InMemoryTransactionsStore, OrderedCollectionStore } from '../../src/persistence';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { WalletProviderStub, mockWalletProvider, queryTransactionsResult } from '../mocks';
import { bufferCount, firstValueFrom, of } from 'rxjs';
import { createTestScheduler } from '../testScheduler';
import delay from 'delay';

describe('TransactionsTracker', () => {
  describe('createAddressTransactionsProvider', () => {
    let store: InMemoryTransactionsStore;
    let walletProvider: WalletProviderStub;
    const tip$ = of(300);
    const retryBackoffConfig = { initialInterval: 1 }; // not relevant
    const addresses = [queryTransactionsResult[0].body.inputs[0].address];

    beforeEach(() => {
      walletProvider = mockWalletProvider();
      store = new InMemoryTransactionsStore();
      store.setAll = jest.fn().mockImplementation(store.setAll.bind(store));
    });

    it('if store is empty, stores and emits transactions resolved by WalletProvider', async () => {
      const provider$ = createAddressTransactionsProvider(
        walletProvider,
        of(addresses),
        retryBackoffConfig,
        tip$,
        store
      );
      expect(await firstValueFrom(provider$)).toEqual(queryTransactionsResult);
      expect(store.setAll).toBeCalledTimes(1);
      expect(store.setAll).toBeCalledWith(queryTransactionsResult);
    });

    it('emits existing transactions from store, then transactions resolved by WalletProvider', async () => {
      await firstValueFrom(store.setAll([queryTransactionsResult[0]]));
      walletProvider.queryTransactionsByAddresses = jest
        .fn()
        .mockImplementation(() => delay(50).then(() => queryTransactionsResult));
      const provider$ = createAddressTransactionsProvider(
        walletProvider,
        of(addresses),
        retryBackoffConfig,
        tip$,
        store
      );
      expect(await firstValueFrom(provider$.pipe(bufferCount(2)))).toEqual([
        [queryTransactionsResult[0]],
        queryTransactionsResult
      ]);
      expect(store.setAll).toBeCalledTimes(2);
      expect(walletProvider.queryTransactionsByAddresses).toBeCalledTimes(1);
      expect(walletProvider.queryTransactionsByAddresses).toBeCalledWith(
        addresses,
        queryTransactionsResult[0].blockHeader.blockNo
      );
    });

    it('queries WalletProvider again with sinceBlock from a previous transaction on rollback', async () => {
      await firstValueFrom(store.setAll(queryTransactionsResult));
      walletProvider.queryTransactionsByAddresses = jest
        .fn()
        .mockImplementationOnce(() => delay(50).then(() => []))
        .mockImplementationOnce(() => delay(50).then(() => [queryTransactionsResult[0]]));
      const provider$ = createAddressTransactionsProvider(
        walletProvider,
        of(addresses),
        retryBackoffConfig,
        tip$,
        store
      );
      expect(await firstValueFrom(provider$.pipe(bufferCount(2)))).toEqual([
        queryTransactionsResult,
        [queryTransactionsResult[0]]
      ]);
      expect(store.setAll).toBeCalledTimes(2);
      expect(walletProvider.queryTransactionsByAddresses).toBeCalledTimes(2);
      expect(walletProvider.queryTransactionsByAddresses).nthCalledWith(
        1,
        addresses,
        queryTransactionsResult[1].blockHeader.blockNo
      );
      expect(walletProvider.queryTransactionsByAddresses).nthCalledWith(
        2,
        addresses,
        queryTransactionsResult[0].blockHeader.blockNo
      );
    });
  });

  describe('createTransactionsTracker', () => {
    // these variables are not relevant for tests, because
    // they're using mock transactionsSource$
    let retryBackoffConfig: RetryBackoffConfig;
    let walletProvider: WalletProvider;
    let store: OrderedCollectionStore<Cardano.TxAlonzo>;
    const myAddress = queryTransactionsResult[0].body.inputs[0].address;
    const addresses$ = of([myAddress]);

    beforeEach(() => {
      store = new InMemoryTransactionsStore();
    });

    it('observable properties behave correctly on successful transaction', async () => {
      const outgoingTx = queryTransactionsResult[0];
      const incomingTx = queryTransactionsResult[1];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const failedToSubmit$ = hot<FailedTx>('----|');
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = hot('-a--|', { a: outgoingTx });
        const pending$ = hot('--a-|', { a: outgoingTx });
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [incomingTx, outgoingTx]
        });
        const confirmedSubscription = '--^--'; // regression: subscribing after submitting$ emits
        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            store,
            tip$,
            walletProvider
          },
          {
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.incoming$).toBe('--a-|', { a: incomingTx });
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.confirmed$, confirmedSubscription).toBe('---a|', {
          a: outgoingTx
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', { a: [], b: [outgoingTx], c: [] });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
        expectObservable(transactionsTracker.history.incoming$).toBe('a-b-|', {
          a: [],
          b: [incomingTx]
        });
        expectObservable(transactionsTracker.history.outgoing$).toBe('a--b|', {
          a: [],
          b: [outgoingTx]
        });
        expectObservable(transactionsTracker.history.all$).toBe('a-bc|', {
          a: [],
          b: [
            {
              direction: TransactionDirection.Incoming,
              tx: incomingTx
            }
          ],
          c: [
            { direction: TransactionDirection.Outgoing, tx: outgoingTx },
            { direction: TransactionDirection.Incoming, tx: incomingTx }
          ]
        });
      });
    });

    it('emits at all relevant observable properties on timed out transaction', async () => {
      const tx = queryTransactionsResult[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const tip = { slot: tx.body.validityInterval.invalidHereafter! + 1 } as Cardano.Tip;
        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = hot<Cardano.Tip>('----a|', { a: tip });
        const submitting$ = hot('-a---|', { a: tx });
        const pending$ = hot('---a-|', { a: tx });
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('-----|');
        const failedSubscription = '--^---'; // regression: subscribing after submitting$ emits
        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            store,
            tip$,
            walletProvider
          },
          {
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a---|', { a: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('---a-|', { a: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab--c|', {
          a: [],
          b: [tx],
          c: []
        });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('-----|');
        expectObservable(transactionsTracker.outgoing.failed$, failedSubscription).toBe('----a|', {
          a: { reason: TransactionFailure.Timeout, tx }
        });
      });
    });

    it('emits at all relevant observable properties on transaction that failed to submit', async () => {
      const tx = queryTransactionsResult[0];
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = cold('-a--|', { a: tx });
        const pending$ = cold('--a-|', { a: tx });
        const transactionsSource$ = cold<Cardano.TxAlonzo[]>('----|');
        const failedToSubmit$ = hot<FailedTx>('---a|', {
          a: { reason: TransactionFailure.FailedToSubmit, tx }
        });
        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            store,
            tip$,
            walletProvider
          },
          {
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', { a: [], b: [tx], c: [] });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('----|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('---a|', {
          a: { reason: TransactionFailure.FailedToSubmit, tx }
        });
      });
    });
  });
});
