/* eslint-disable max-len */
/* eslint-disable space-in-parens */
/* eslint-disable no-multi-spaces */
/* eslint-disable prettier/prettier */
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { ChainHistoryProviderStub, generateTxAlonzo, mockChainHistoryProvider, queryTransactionsResult } from '../mocks';
import {
  FailedTx,
  PAGE_SIZE,
  TransactionFailure,
  TxInFlight,
  createAddressTransactionsProvider,
  createTransactionsTracker
} from '../../src';
import { InMemoryInFlightTransactionsStore, InMemoryTransactionsStore, WalletStores } from '../../src/persistence';
import { NEVER, bufferCount, firstValueFrom, map, of } from 'rxjs';
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
            rollback$: NEVER,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.confirmed$, confirmedSubscription).toBe('---a|', {
          a: { confirmedAt: outgoingTx.blockHeader.slot, tx: outgoingTx }
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', {
          a: [],
          b: [{ tx: outgoingTx }],
          c: []
        });
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
        const tip1 = { slot: tx.body.validityInterval!.invalidHereafter! - 1 } as Cardano.Tip;
        const tip2 = { slot: tx.body.validityInterval!.invalidHereafter! + 1 } as Cardano.Tip;
        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = hot<Cardano.Tip>('--ab-|', { a: tip1, b: tip2 });
        const submitting$ = hot('-a---|', { a: tx });
        const pending$ = hot('--a--|', { a: tx });
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
            rollback$: NEVER,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a---|', { a: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a--|', { a: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abcd-|', {
          a: [],
          b: [{ tx }],
          c: [{ submittedAt: tip1.slot, tx }],
          d: []
        });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('-----|');
        expectObservable(transactionsTracker.outgoing.failed$, failedSubscription).toBe('---a-|', {
          a: { reason: TransactionFailure.Timeout, tx }
        });
      });
    });

    it(`resubmitting (emitting at pending$) a tx that was already confirmed or failed does not re-add the tx to inFlight$;
        rollback of a transaction of which an output was used in a pending transaction interprets transaction as failed`, async () => {
      const tx = queryTransactionsResult.pageResults[0];
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const tip1 = { slot: tx.body.validityInterval!.invalidHereafter! - 1 } as Cardano.Tip;
        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = cold('a', { a: tip1 });
        const submitting$ = hot('-a---|', { a: tx });
        const pending$ = hot(   '--a-a|', { a: tx }); // second emission must not re-add it to inFlight$
        const rollback$ = hot(  '---a-|', { a: { id: tx.body.inputs[0].txId } as Cardano.TxAlonzo });
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('-----|');
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
            rollback$,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe(                         '-a---|', { a: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe(                            '--a-a|', { a: tx });
        expectObservable(transactionsTracker.outgoing.failed$.pipe(map(err => err.reason))).toBe('---a-|', {
          a: TransactionFailure.InvalidTransaction
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abcd-|', {
          a: [],
          b: [{ tx }],
          c: [{ submittedAt: tip1.slot, tx }],
          d: []
        });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('-----|');
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
            rollback$: NEVER,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', { a: [], b: [{ tx }], c: [] });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('----|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('---a|', {
          a: { reason: TransactionFailure.FailedToSubmit, tx }
        });
      });
    });

    it('does not double-track confirmations of resubmitted transactions', async () => {
      const tx = queryTransactionsResult.pageResults[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const submittedAt1 = 123;
        const submittedAt2 = 124;
        const tip$ = hot('--a-b-|', {
          a: { slot: submittedAt1 } as Cardano.Tip,
          b: { slot: submittedAt2 } as Cardano.Tip
        });
        const submitting$ = hot('-a-b--|', { a: tx, b: tx });
        const pending$ = hot(   '--a-b-|', { a: tx, b: tx });
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('-a---b|', {
          a: [],
          b: [tx]
        });
        const failedToSubmit$ = hot<FailedTx>('------|');
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
            rollback$: NEVER,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a-b--|', { a: tx, b: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe(   '--a-b-|', { a: tx, b: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe(  'abcdef|', {
          a: [],
          b: [{ tx }],
          c: [{ submittedAt: submittedAt1, tx }],
          d: [{ tx }],
          e: [{ submittedAt: submittedAt2, tx }],
          f: []
        });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('-----a|', {
          a: { confirmedAt: tx.blockHeader.slot, tx }
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('------|');
      });
    });

    it('does not double-track failures of resubmitted transactions', async () => {
      const tx = queryTransactionsResult.pageResults[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const submittedAt1 = 123;
        const submittedAt2 = 124;
        const tip$ = hot(                                   '--a-b-|', {
          a: { slot: submittedAt1 } as Cardano.Tip,
          b: { slot: submittedAt2 } as Cardano.Tip
        });
        const submitting$ = hot(                            '-a-b--|', { a: tx, b: tx });
        const pending$ = hot<Cardano.NewTxAlonzo>(          '------|');
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('a-----|', { a: [] });
        const failedToSubmit$ = hot<FailedTx>(              '-----a|', {
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
            rollback$: NEVER,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a-b--|', { a: tx, b: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe(  'ab-c-a|', { a: [], b: [{ tx }], c: [{ tx }] });
        expectObservable(transactionsTracker.outgoing.failed$).toBe(    '-----a|', {
          a: { reason: TransactionFailure.FailedToSubmit, tx }
        });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe( '------|');
      });
    });

    it('pending$ transactions updates inFlight$ with submittedAt from current tip$', async () => {
      const tx = queryTransactionsResult.pageResults[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const submittedAt = 123;
        const tip$ = hot<Cardano.Tip>('--a-|', { a: { slot: submittedAt } as Cardano.Tip });
        const submitting$ = hot('-a--|', { a: tx });
        const pending$ = hot('--a-|', { a: tx });
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('a--b|', {
          a: [],
          b: [tx]
        });
        const failedToSubmit$ = hot<FailedTx>('----|');
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
            rollback$: NEVER,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abcd|', {
          a: [],
          b: [{ tx }],
          c: [{ submittedAt, tx }],
          d: []
        });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('---a|', {
          a: { confirmedAt: tx.blockHeader.slot, tx }
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
      });
    });

    it('stored inFlight transactions are restored and merged with submitting ones', async () => {
      const storedInFlightTransaction: TxInFlight = {
        submittedAt: 1,
        tx: { body: { validityInterval: { invalidHereafter: 1 } } } as Cardano.NewTxAlonzo
      };
      const outgoingTx = queryTransactionsResult.pageResults[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const storedInFlight$ = hot<TxInFlight[]>('-x|', {
          x: [storedInFlightTransaction]
        });
        inFlightTransactionsStore.get = jest.fn(() => storedInFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('|');
        const tip$ = hot<Cardano.Tip>('|');
        const submitting$ = hot('--a|', { a: outgoingTx });
        const pending$ = hot<Cardano.NewTxAlonzo>('|');
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
            rollback$: NEVER,
            transactionsSource$
          }
        );

        expectObservable(transactionsTracker.outgoing.pending$).toBe('|');
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('---|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('---|');

        expectObservable(transactionsTracker.outgoing.submitting$).toBe('--b|', {
          b: outgoingTx
        });

        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abc|', {
          a: [],
          b: [storedInFlightTransaction],
          c: [storedInFlightTransaction, { tx: outgoingTx }]
        });
      });
      expect(inFlightTransactionsStore.set).toHaveBeenCalledTimes(2);
      expect(inFlightTransactionsStore.set).lastCalledWith([storedInFlightTransaction, { tx: outgoingTx }]);
    });

    it('inFlight transactions are removed from store on successful transaction', async () => {
      const outgoingTx = queryTransactionsResult.pageResults[0];
      const incomingTx = queryTransactionsResult.pageResults[1];
      const storedInFlightTransaction = outgoingTx;

      createTestScheduler().run(({ hot, expectObservable }) => {
        const storedInFlight = { submittedAt: 1, tx: storedInFlightTransaction };
        const storedInFlight$ = hot<TxInFlight[]>('-x|', {
          x: [storedInFlight]
        });
        inFlightTransactionsStore.get = jest.fn(() => storedInFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('----|');
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = hot<Cardano.NewTxAlonzo>('----|');
        const pending$ = hot<Cardano.NewTxAlonzo>('----|');
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
            rollback$: NEVER,
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('----|');
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe('---a|', {
          a: { confirmedAt: storedInFlightTransaction.blockHeader.slot, tx: storedInFlightTransaction }
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-a|', {
          a: [],
          b: [storedInFlight]
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
        submittedAt: 1,
        tx: {
          body: { validityInterval: {} },
          id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa')
        } as Cardano.NewTxAlonzo
      };
      const incomingTx = {
        blockHeader: { blockNo: 1_000_000 },
        body: { validityInterval: {} },
        // should remove storedInFlightTx from inFlight$ once confirmed
        id: storedInFlightTx.tx.id
      } as Cardano.TxAlonzo;

      createTestScheduler().run(({ hot, expectObservable }) => {
        const storedInFlight$ = hot<TxInFlight[]>('-a|', {
          a: [storedInFlightTx]
        });
        inFlightTransactionsStore.get = jest.fn(() => storedInFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = hot<Cardano.Tip>('-----|');
        const submitting$ = hot<Cardano.NewTxAlonzo>('--a--|', { a: outgoingTx });
        const pending$ = hot<Cardano.NewTxAlonzo>('-----|');
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
            rollback$: NEVER,
            transactionsSource$
          }
        );

        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abc-d|', {
          a: [],
          b: [storedInFlightTx],
          c: [storedInFlightTx, { tx: outgoingTx }],
          d: [{ tx: outgoingTx }]
        });
      });
      expect(inFlightTransactionsStore.set).toHaveBeenCalledTimes(3);
      expect(inFlightTransactionsStore.set).lastCalledWith([{ tx: outgoingTx }]);
    });
  });
});
