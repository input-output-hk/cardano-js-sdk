import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { ChainHistoryProviderStub, mockChainHistoryProvider, queryTransactionsResult } from '../mocks';
import { FailedTx, TransactionFailure, createAddressTransactionsProvider, createTransactionsTracker } from '../../src';
import { InMemoryInFlightTransactionsStore, InMemoryTransactionsStore, WalletStores } from '../../src/persistence';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { bufferCount, firstValueFrom, of } from 'rxjs';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import delay from 'delay';

describe('TransactionsTracker', () => {
  describe('createAddressTransactionsProvider', () => {
    let store: InMemoryTransactionsStore;
    let chainHistoryProvider: ChainHistoryProviderStub;
    const tip$ = of(300);
    const retryBackoffConfig = { initialInterval: 1 }; // not relevant
    const addresses = [queryTransactionsResult[0].body.inputs[0].address!];

    beforeEach(() => {
      chainHistoryProvider = mockChainHistoryProvider();
      store = new InMemoryTransactionsStore();
      store.setAll = jest.fn().mockImplementation(store.setAll.bind(store));
    });

    it('if store is empty, stores and emits transactions resolved by ChainHistoryProvider', async () => {
      const provider$ = createAddressTransactionsProvider(
        chainHistoryProvider,
        of(addresses),
        retryBackoffConfig,
        tip$,
        store
      );
      expect(await firstValueFrom(provider$)).toEqual(queryTransactionsResult);
      expect(store.setAll).toBeCalledTimes(1);
      expect(store.setAll).toBeCalledWith(queryTransactionsResult);
    });

    it('emits existing transactions from store, then transactions resolved by ChainHistoryProvider', async () => {
      await firstValueFrom(store.setAll([queryTransactionsResult[0]]));
      chainHistoryProvider.transactionsByAddresses = jest
        .fn()
        .mockImplementation(() => delay(50).then(() => queryTransactionsResult));
      const provider$ = createAddressTransactionsProvider(
        chainHistoryProvider,
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
      expect(chainHistoryProvider.transactionsByAddresses).toBeCalledTimes(1);
      expect(chainHistoryProvider.transactionsByAddresses).toBeCalledWith({
        addresses,
        sinceBlock: queryTransactionsResult[0].blockHeader.blockNo
      });
    });

    it('queries ChainHistoryProvider again with sinceBlock from a previous transaction on rollback', async () => {
      await firstValueFrom(store.setAll(queryTransactionsResult));
      chainHistoryProvider.transactionsByAddresses = jest
        .fn()
        .mockImplementationOnce(() => delay(50).then(() => []))
        .mockImplementationOnce(() => delay(50).then(() => [queryTransactionsResult[0]]));
      const provider$ = createAddressTransactionsProvider(
        chainHistoryProvider,
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
      expect(chainHistoryProvider.transactionsByAddresses).toBeCalledTimes(2);
      expect(chainHistoryProvider.transactionsByAddresses).nthCalledWith(1, {
        addresses,
        sinceBlock: queryTransactionsResult[1].blockHeader.blockNo
      });
      expect(chainHistoryProvider.transactionsByAddresses).nthCalledWith(2, {
        addresses,
        sinceBlock: queryTransactionsResult[0].blockHeader.blockNo
      });
    });
  });

  describe('createTransactionsTracker', () => {
    // these variables are not relevant for tests, because
    // they're using mock transactionsSource$
    let retryBackoffConfig: RetryBackoffConfig;
    let chainHistoryProvider: ChainHistoryProvider;
    let transactionsStore: WalletStores['transactions'];
    let inFlightTransactionsStore: WalletStores['inFlightTransactions'];
    const myAddress = queryTransactionsResult[0].body.inputs[0].address;
    const addresses$ = of([myAddress!]);

    beforeEach(() => {
      transactionsStore = new InMemoryTransactionsStore();
      inFlightTransactionsStore = new InMemoryInFlightTransactionsStore();
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
            chainHistoryProvider,
            inFlightTransactionsStore,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            tip$,
            transactionsHistoryStore: transactionsStore
          },
          {
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.confirmed$, confirmedSubscription).toBe('---a|', {
          a: outgoingTx
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', { a: [], b: [outgoingTx], c: [] });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
        expectObservable(transactionsTracker.history$).toBe('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [outgoingTx, incomingTx]
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
            chainHistoryProvider,
            inFlightTransactionsStore,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            tip$,
            transactionsHistoryStore: transactionsStore
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
            chainHistoryProvider,
            inFlightTransactionsStore,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            tip$,
            transactionsHistoryStore: transactionsStore
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

    it('stored inFlight transactions are restored and merged with submitting ones', async () => {
      const storedInFlightTransaction = { body: { validityInterval: { invalidHereafter: 1 } } } as Cardano.NewTxAlonzo;
      const outgoingTx = queryTransactionsResult[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const inFlight$ = hot<Cardano.NewTxAlonzo[]>('-x|', {
          x: [storedInFlightTransaction]
        });
        inFlightTransactionsStore.get = jest.fn(() => inFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('|');
        const tip$ = hot<Cardano.Tip>('|');
        const submitting$ = hot('--a|', { a: outgoingTx });
        const pending$ = hot<Cardano.TxAlonzo>('|');
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('|');

        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            chainHistoryProvider,
            inFlightTransactionsStore,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            tip$,
            transactionsHistoryStore: transactionsStore
          },
          {
            transactionsSource$
          }
        );

        expectObservable(transactionsTracker.outgoing.pending$).toBe('|');
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('---|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('---|');

        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-ab|', {
          a: storedInFlightTransaction,
          b: outgoingTx
        });

        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abc|', {
          a: [],
          b: [storedInFlightTransaction],
          c: [storedInFlightTransaction, outgoingTx]
        });
      });
      expect(inFlightTransactionsStore.set).toHaveBeenCalledTimes(2);
      expect(inFlightTransactionsStore.set).lastCalledWith([storedInFlightTransaction, outgoingTx]);
    });

    it('inFlight transactions are removed from store on successful transaction', async () => {
      const outgoingTx = queryTransactionsResult[0];
      const incomingTx = queryTransactionsResult[1];
      const storedInFlightTransaction = outgoingTx;

      createTestScheduler().run(({ hot, expectObservable }) => {
        const inFlight$ = hot<Cardano.NewTxAlonzo[]>('-x|', {
          x: [storedInFlightTransaction]
        });
        inFlightTransactionsStore.get = jest.fn(() => inFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('----|');
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = hot<Cardano.NewTxAlonzo>('----|');
        const pending$ = hot<Cardano.TxAlonzo>('----|');
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [incomingTx, outgoingTx]
        });

        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            chainHistoryProvider,
            inFlightTransactionsStore,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            tip$,
            transactionsHistoryStore: transactionsStore
          },
          {
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: storedInFlightTransaction });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('---a|', {
          a: storedInFlightTransaction
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-a|', {
          a: [],
          b: [storedInFlightTransaction]
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
        expectObservable(transactionsTracker.history$).toBe('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [outgoingTx, incomingTx]
        });
      });
      expect(inFlightTransactionsStore.set).toHaveBeenCalledTimes(2);
      expect(inFlightTransactionsStore.set).lastCalledWith([]);
    });

    it('inFlight mixed with submitting transactions are removed from store on successful transaction', async () => {
      // transaction body doesn't matter
      const outgoingTx = {
        body: { validityInterval: {} },
        id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
      } as Cardano.NewTxAlonzo;
      const storedInFlightTx = {
        body: { validityInterval: {} },
        id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa')
      } as Cardano.NewTxAlonzo;
      const incomingTx = {
        blockHeader: { blockNo: 1_000_000 },
        body: { validityInterval: {} },
        // should remove storedInFlightTx from inFlight$ once confirmed
        id: storedInFlightTx.id
      } as Cardano.TxAlonzo;

      createTestScheduler().run(({ hot, expectObservable }) => {
        const inFlight$ = hot<Cardano.NewTxAlonzo[]>('-a|', {
          a: [storedInFlightTx]
        });
        inFlightTransactionsStore.get = jest.fn(() => inFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = hot<Cardano.Tip>('-----|');
        const submitting$ = hot<Cardano.NewTxAlonzo>('--a--|', { a: outgoingTx });
        const pending$ = hot<Cardano.TxAlonzo>('-----|');
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('a---b|', {
          a: [],
          b: [incomingTx]
        });

        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            chainHistoryProvider,
            inFlightTransactionsStore,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
            tip$,
            transactionsHistoryStore: transactionsStore
          },
          {
            transactionsSource$
          }
        );

        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abc-d|', {
          a: [],
          b: [storedInFlightTx],
          c: [storedInFlightTx, outgoingTx],
          d: [outgoingTx]
        });
      });
      expect(inFlightTransactionsStore.set).toHaveBeenCalledTimes(3);
      expect(inFlightTransactionsStore.set).lastCalledWith([outgoingTx]);
    });
  });
});
