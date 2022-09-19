/* eslint-disable max-len */
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import {
  ChainHistoryProviderStub,
  generateTxAlonzo,
  mockChainHistoryProvider,
  queryTransactionsResult
} from '../mocks';
import { EMPTY, bufferCount, firstValueFrom, of } from 'rxjs';
import {
  FailedTx,
  PAGE_SIZE,
  TransactionFailure,
  createAddressTransactionsProvider,
  createTransactionsTracker
} from '../../src';
import { InMemoryInFlightTransactionsStore, InMemoryTransactionsStore, WalletStores } from '../../src/persistence';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { dummyLogger } from 'ts-log';
import delay from 'delay';

describe('TransactionsTracker', () => {
  const logger = dummyLogger;

  describe('createAddressTransactionsProvider', () => {
    let store: InMemoryTransactionsStore;
    let chainHistoryProvider: ChainHistoryProviderStub;
    const tipBlockHeight$ = of(300);
    const retryBackoffConfig = { initialInterval: 1 }; // not relevant
    const addresses = [queryTransactionsResult.pageResults[0].body.inputs[0].address!];

    beforeEach(() => {
      chainHistoryProvider = mockChainHistoryProvider();
      store = new InMemoryTransactionsStore();
      store.setAll = jest.fn().mockImplementation(store.setAll.bind(store));
    });

    it('if store is empty, stores and emits transactions resolved by ChainHistoryProvider', async () => {
      const provider$ = createAddressTransactionsProvider({
        addresses$: of(addresses),
        chainHistoryProvider,
        logger,
        retryBackoffConfig,
        store,
        tipBlockHeight$
      }).transactionsSource$;
      expect(await firstValueFrom(provider$)).toEqual(queryTransactionsResult.pageResults);
      expect(store.setAll).toBeCalledTimes(1);
      expect(store.setAll).toBeCalledWith(queryTransactionsResult.pageResults);
    });

    it('emits entire transactions list resolved by ChainHistoryProvider', async () => {
      const pageSize = PAGE_SIZE;
      const secondPageSize = 5;
      const totalTxsCount = pageSize + secondPageSize;

      const firstPageTxs = {
        pageResults: generateTxAlonzo(pageSize),
        totalResultCount: totalTxsCount
      };
      const secondPageTxs = {
        pageResults: generateTxAlonzo(secondPageSize),
        totalResultCount: totalTxsCount
      };
      chainHistoryProvider.transactionsByAddresses = jest
        .fn()
        .mockResolvedValueOnce(firstPageTxs)
        .mockResolvedValueOnce(secondPageTxs);

      const provider$ = createAddressTransactionsProvider({
        addresses$: of(addresses),
        chainHistoryProvider,
        logger,
        retryBackoffConfig,
        store,
        tipBlockHeight$
      }).transactionsSource$;

      const transactionsHistory = await firstValueFrom(provider$);
      expect(transactionsHistory.length).toEqual(totalTxsCount);
      expect(transactionsHistory).toEqual([...firstPageTxs.pageResults, ...secondPageTxs.pageResults]);
      expect(store.setAll).toBeCalledWith([...firstPageTxs.pageResults, ...secondPageTxs.pageResults]);
    });

    it('emits existing transactions from store, then transactions resolved by ChainHistoryProvider', async () => {
      await firstValueFrom(store.setAll([queryTransactionsResult.pageResults[0]]));
      chainHistoryProvider.transactionsByAddresses = jest
        .fn()
        .mockImplementation(() => delay(50).then(() => queryTransactionsResult));
      const provider$ = createAddressTransactionsProvider({
        addresses$: of(addresses),
        chainHistoryProvider,
        logger,
        retryBackoffConfig,
        store,
        tipBlockHeight$
      }).transactionsSource$;
      expect(await firstValueFrom(provider$.pipe(bufferCount(2)))).toEqual([
        [queryTransactionsResult.pageResults[0]],
        queryTransactionsResult.pageResults
      ]);
      expect(store.setAll).toBeCalledTimes(2);
      expect(chainHistoryProvider.transactionsByAddresses).toBeCalledTimes(1);
      expect(chainHistoryProvider.transactionsByAddresses).toBeCalledWith({
        addresses,
        blockRange: { lowerBound: queryTransactionsResult.pageResults[0].blockHeader.blockNo },
        pagination: { limit: 25, startAt: 0 }
      });
    });

    it('queries ChainHistoryProvider again with blockRange lower bound from a previous transaction on rollback', async () => {
      await firstValueFrom(store.setAll(queryTransactionsResult.pageResults));
      chainHistoryProvider.transactionsByAddresses = jest
        .fn()
        .mockImplementationOnce(() => delay(50).then(() => ({ pageResults: [], totalResultCount: 0 })))
        .mockImplementationOnce(() => delay(50).then(() => ({ pageResults: [], totalResultCount: 0 })))
        .mockImplementationOnce(() =>
          delay(50).then(() => ({ pageResults: [queryTransactionsResult.pageResults[0]], totalResultCount: 1 }))
        );
      const { transactionsSource$: provider$, rollback$ } = createAddressTransactionsProvider({
        addresses$: of(addresses),
        chainHistoryProvider,
        logger,
        retryBackoffConfig,
        store,
        tipBlockHeight$
      });

      const rollbacks: Cardano.TxAlonzo[] = [];
      rollback$.subscribe((tx) => rollbacks.push(tx));

      expect(await firstValueFrom(provider$.pipe(bufferCount(2)))).toEqual([
        queryTransactionsResult.pageResults, // from store
        [queryTransactionsResult.pageResults[0]] // store + chain history
      ]);

      expect(rollbacks).toEqual([queryTransactionsResult.pageResults[1], queryTransactionsResult.pageResults[0]]);

      expect(store.setAll).toBeCalledTimes(2);
      expect(chainHistoryProvider.transactionsByAddresses).toBeCalledTimes(3);
      expect(chainHistoryProvider.transactionsByAddresses).nthCalledWith(1, {
        addresses,
        blockRange: { lowerBound: queryTransactionsResult.pageResults[1].blockHeader.blockNo },
        pagination: { limit: 25, startAt: 0 }
      });
      expect(chainHistoryProvider.transactionsByAddresses).nthCalledWith(2, {
        addresses,
        blockRange: { lowerBound: queryTransactionsResult.pageResults[0].blockHeader.blockNo },
        pagination: { limit: 25, startAt: 0 }
      });
      expect(chainHistoryProvider.transactionsByAddresses).nthCalledWith(3, {
        addresses,
        blockRange: { lowerBound: undefined },
        pagination: { limit: 25, startAt: 0 }
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
    const myAddress = queryTransactionsResult.pageResults[0].body.inputs[0].address;
    const addresses$ = of([myAddress!]);

    beforeEach(() => {
      transactionsStore = new InMemoryTransactionsStore();
      inFlightTransactionsStore = new InMemoryInFlightTransactionsStore();
    });

    it('observable properties behave correctly on successful transaction', async () => {
      const outgoingTx = queryTransactionsResult.pageResults[0];
      const incomingTx = queryTransactionsResult.pageResults[1];
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
            logger,
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
            rollback$: EMPTY,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.confirmed$, confirmedSubscription).toBe('---a|', {
          a: { ...outgoingTx, slot: outgoingTx.blockHeader.slot }
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
      const tx = queryTransactionsResult.pageResults[0];
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
            logger,
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
            rollback$: EMPTY,
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
      const tx = queryTransactionsResult.pageResults[0];
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
            logger,
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
            rollback$: EMPTY,
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
      const outgoingTx = queryTransactionsResult.pageResults[0];
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
            logger,
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
            rollback$: EMPTY,
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
      const outgoingTx = queryTransactionsResult.pageResults[0];
      const incomingTx = queryTransactionsResult.pageResults[1];
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
            logger,
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
            rollback$: EMPTY,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: storedInFlightTransaction });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('---a|', {
          a: { ...storedInFlightTransaction, slot: storedInFlightTransaction.blockHeader.slot }
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
            logger,
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
            rollback$: EMPTY,
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
