/* eslint-disable space-in-parens */
/* eslint-disable no-multi-spaces */
/* eslint-disable prettier/prettier */
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import {
  FailedTx,
  OutgoingTx,
  PAGE_SIZE,
  TransactionFailure,
  TxInFlight,
  createAddressTransactionsProvider,
  createTransactionsTracker,
  newTransactions$
} from '../../src';
import { InMemoryInFlightTransactionsStore, InMemoryTransactionsStore, WalletStores } from '../../src/persistence';
import { NEVER, bufferCount, firstValueFrom, map, of } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { createTestScheduler, mockProviders } from '@cardano-sdk/util-dev';
import { dummyCbor, toOutgoingTx } from '../util';
import { dummyLogger } from 'ts-log';
import delay from 'delay';

const {
  generateTxAlonzo,
  mockChainHistoryProvider,
  queryTransactionsResult
} = mockProviders;

describe('TransactionsTracker', () => {
  const logger = dummyLogger;

  describe('newTransactions$', () => {
    it('considers transactions from 1st emission as old and emits only new transactions', () => {
      createTestScheduler().run(({ hot, expectObservable }) => {
        const history$ = hot('a-b', {
          a: [{ id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000') }],
          b: [
            { id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000') },
            { id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000001') }
          ]
        });
        expectObservable(newTransactions$(history$)).toBe('--b', {
          b: { id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000001') }
        });
      });
    });
  });

  describe('createAddressTransactionsProvider', () => {
    let store: InMemoryTransactionsStore;
    let chainHistoryProvider: mockProviders.ChainHistoryProviderStub;
    const tipBlockHeight$ = of(Cardano.BlockNo(300));
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

      const rollbacks: Cardano.HydratedTx[] = [];
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
      const submittedTx = queryTransactionsResult.pageResults[0];
      const outgoingTx = toOutgoingTx(submittedTx);
      const incomingTx = queryTransactionsResult.pageResults[1];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const failedToSubmit$ = hot<FailedTx>('----|');
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = hot('-a--|', { a: outgoingTx });
        const pending$ = hot('--a-|', { a: outgoingTx });
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [incomingTx, submittedTx]
        });
        const onChainSubscription = '--^--'; // regression: subscribing after submitting$ emits
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
        expectObservable(transactionsTracker.outgoing.onChain$, onChainSubscription).toBe('---a|', {
          a: { slot: submittedTx.blockHeader.slot, ...outgoingTx }
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', {
          a: [],
          b: [outgoingTx],
          c: []
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
        expectObservable(transactionsTracker.history$).toBe('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [submittedTx, incomingTx]
        });
      });
    });

    it('emits at all relevant observable properties on timed out transaction', async () => {
      const tx = queryTransactionsResult.pageResults[0];
      const outgoingTx = toOutgoingTx(tx);
      createTestScheduler().run(({ hot, expectObservable }) => {
        const tip1 = { slot: Cardano.Slot(tx.body.validityInterval!.invalidHereafter! - 1) } as Cardano.Tip;
        const tip2 = { slot: Cardano.Slot(tx.body.validityInterval!.invalidHereafter! + 1) } as Cardano.Tip;
        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = hot<Cardano.Tip>('--ab-|', { a: tip1, b: tip2 });
        const submitting$ = hot('-a---|', { a: outgoingTx });
        const pending$ = hot('--a--|', { a: outgoingTx });
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('-----|');
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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a---|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abcd-|', {
          a: [],
          b: [outgoingTx],
          c: [{ submittedAt: tip1.slot, ...outgoingTx }],
          d: []
        });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('-----|');
        expectObservable(transactionsTracker.outgoing.failed$, failedSubscription).toBe('---a-|', {
          a: { reason: TransactionFailure.Timeout, ...outgoingTx }
        });
      });
    });

    it(`resubmitting (emitting at pending$) a tx that was already on-chain or failed does not re-add the tx to inFlight$;
        rollback of a transaction of which an output was used in a pending transaction interprets transaction as failed`, async () => {
      const tx = queryTransactionsResult.pageResults[0];
      const outgoingTx = toOutgoingTx(tx);
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const tip1 = { slot: Cardano.Slot(tx.body.validityInterval!.invalidHereafter! - 1) } as Cardano.Tip;
        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = cold('a', { a: tip1 });
        const submitting$ = hot('-a---|', { a: outgoingTx });
        const pending$ = hot('--a-a|', { a: outgoingTx }); // second emission must not re-add it to inFlight$
        const rollback$ = hot('---a-|', { a: { id: tx.body.inputs[0].txId } as Cardano.HydratedTx });
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('-----|');
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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a---|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-a|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.failed$.pipe(map((err) => err.reason))).toBe('---a-|', {
          a: TransactionFailure.InvalidTransaction
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abcd-|', {
          a: [],
          b: [outgoingTx],
          c: [{ submittedAt: tip1.slot, ...outgoingTx }],
          d: []
        });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('-----|');
      });
    });

    it('emits phase 2 validation on-chain transactions as failed$', async () => {
      const outgoingTx = toOutgoingTx(queryTransactionsResult.pageResults[0]);
      const phase2FailedTx: Cardano.HydratedTx = {
        ...queryTransactionsResult.pageResults[0],
        inputSource: Cardano.InputSource.collaterals
      };

      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const tip$ = hot<Cardano.Tip>('-----|');
        const submitting$ = cold('-a---|', { a: outgoingTx });
        const pending$ = cold('--a--|', { a: outgoingTx });
        const transactionsSource$ = cold<Cardano.HydratedTx[]>('a--b-|', { a: [], b: [phase2FailedTx] });
        const failedToSubmit$ = hot<FailedTx>('-----|');

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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a---|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c-|', { a: [], b: [outgoingTx], c: [] });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('-----|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('---a-|', {
          a: { reason: TransactionFailure.Phase2Validation, ...outgoingTx }
        });
      });
    });

    it('emits at all relevant observable properties on transaction that failed to submit and merges reemit failures', async () => {
      const outgoingTx = toOutgoingTx(queryTransactionsResult.pageResults[0]);
      const outgoingTxReemit = toOutgoingTx(queryTransactionsResult.pageResults[1]);

      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = cold('-a--|', { a: outgoingTx });
        const pending$ = cold('--a-|', { a: outgoingTx });
        const transactionsSource$ = cold<Cardano.HydratedTx[]>('----|');
        const failedToSubmit$ = hot<FailedTx>('---a|', {
          a: { reason: TransactionFailure.FailedToSubmit, ...outgoingTx }
        });
        const failedFromReemitter$ = cold<FailedTx>('-a|', {
          a: { reason: TransactionFailure.Timeout, ...outgoingTxReemit }
        });
        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            chainHistoryProvider,
            failedFromReemitter$,
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
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', { a: [], b: [outgoingTx], c: [] });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('----|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('-a-b|', {
          a: { reason: TransactionFailure.Timeout, ...outgoingTxReemit },
          b: { reason: TransactionFailure.FailedToSubmit, ...outgoingTx }
        });
      });
    });

    // Verify fix for bug where undefined invalidHereafter causes the failed transaction to go undetected
    it('emits failed transaction with undefined invalidHereafter', async () => {
      const outgoingTx = toOutgoingTx(queryTransactionsResult.pageResults[0]);
      outgoingTx.body.validityInterval = undefined;

      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = cold('-a--|', { a: outgoingTx });
        const pending$ = cold('--a-|', { a: outgoingTx });
        const transactionsSource$ = cold<Cardano.HydratedTx[]>('----|');
        const failedToSubmit$ = hot<FailedTx>('---a|', {
          a: { reason: TransactionFailure.FailedToSubmit, ...outgoingTx }
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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c|', { a: [], b: [outgoingTx], c: [] });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('----|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('---a|', {
          a: { reason: TransactionFailure.FailedToSubmit, ...outgoingTx }
        });
      });
    });

    it('does not double-track confirmations of resubmitted transactions', async () => {
      const tx = queryTransactionsResult.pageResults[0];
      const outgoingTx = toOutgoingTx(tx);
      createTestScheduler().run(({ hot, expectObservable }) => {
        const submittedAt1 = Cardano.Slot(123);
        const submittedAt2 = Cardano.Slot(124);
        const tip$ = hot('--a-b-|', {
          a: { slot: submittedAt1 } as Cardano.Tip,
          b: { slot: submittedAt2 } as Cardano.Tip
        });
        const submitting$ = hot('-a-b--|', { a: outgoingTx, b: outgoingTx });
        const pending$ = hot('--a-b-|', { a: outgoingTx, b: outgoingTx });
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('-a---b|', {
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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a-b--|', { a: outgoingTx, b: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-b-|', { a: outgoingTx, b: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abcdef|', {
          a: [],
          b: [outgoingTx],
          c: [{ submittedAt: submittedAt1, ...outgoingTx }],
          d: [outgoingTx],
          e: [{ submittedAt: submittedAt2, ...outgoingTx }],
          f: []
        });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('-----a|', {
          a: { slot: tx.blockHeader.slot, ...outgoingTx }
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('------|');
      });
    });

    it('does not double-track failures of resubmitted transactions', async () => {
      const tx = queryTransactionsResult.pageResults[0];
      const outgoingTx = toOutgoingTx(tx);
      createTestScheduler().run(({ hot, expectObservable }) => {
        const submittedAt1 = Cardano.Slot(123);
        const submittedAt2 = Cardano.Slot(124);
        const tip$ = hot('--a-b-|', {
          a: { slot: submittedAt1 } as Cardano.Tip,
          b: { slot: submittedAt2 } as Cardano.Tip
        });
        const submitting$ = hot('-a-b--|', { a: outgoingTx, b: outgoingTx });
        const pending$ = hot<OutgoingTx>('------|');
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('a-----|', { a: [] });
        const failedToSubmit$ = hot<FailedTx>('-----a|', {
          a: { reason: TransactionFailure.FailedToSubmit, ...outgoingTx }
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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a-b--|', { a: outgoingTx, b: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-c-a|', {
          a: [],
          b: [outgoingTx],
          c: [outgoingTx]
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('-----a|', {
          a: { reason: TransactionFailure.FailedToSubmit, ...outgoingTx }
        });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('------|');
      });
    });

    it('pending$ transactions updates inFlight$ with submittedAt from current tip$', async () => {
      const tx = queryTransactionsResult.pageResults[0];
      const outgoingTx = toOutgoingTx(tx);
      createTestScheduler().run(({ hot, expectObservable }) => {
        const submittedAt = Cardano.Slot(123);
        const tip$ = hot<Cardano.Tip>('--a-|', { a: { slot: submittedAt } as Cardano.Tip });
        const submitting$ = hot('-a--|', { a: outgoingTx });
        const pending$ = hot('--a-|', { a: outgoingTx });
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('a--b|', {
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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('abcd|', {
          a: [],
          b: [outgoingTx],
          c: [{ submittedAt, ...outgoingTx }],
          d: []
        });
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('---a|', {
          a: { slot: tx.blockHeader.slot, ...outgoingTx }
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
      });
    });

    it('stored inFlight transactions are restored and merged with submitting ones', async () => {
      const storedInFlightTransaction: TxInFlight = {
        body: { validityInterval: { invalidHereafter: Cardano.Slot(1) } } as Cardano.TxBody,
        cbor: dummyCbor,
        id: queryTransactionsResult.pageResults[1].id,
        submittedAt: Cardano.Slot(1)
      };
      const submittedTx = queryTransactionsResult.pageResults[0];
      const outgoingTx = toOutgoingTx(submittedTx);
      createTestScheduler().run(({ hot, expectObservable }) => {
        const storedInFlight$ = hot<TxInFlight[]>('-x|', {
          x: [storedInFlightTransaction]
        });
        inFlightTransactionsStore.get = jest.fn(() => storedInFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('|');
        const tip$ = hot<Cardano.Tip>('|');
        const submitting$ = hot('--a|', { a: outgoingTx });
        const pending$ = hot<OutgoingTx>('|');
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('|');

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
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('---|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe('---|');

        expectObservable(transactionsTracker.outgoing.submitting$).toBe('--b|', {
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
      const storedInFlightTx = queryTransactionsResult.pageResults[0];
      const incomingTx = queryTransactionsResult.pageResults[1];
      const storedInFlightOutgoingTx = { submittedAt: Cardano.Slot(1), ...toOutgoingTx(storedInFlightTx) };

      createTestScheduler().run(({ hot, expectObservable }) => {
        const storedInFlight$ = hot<TxInFlight[]>('-x|', {
          x: [storedInFlightOutgoingTx]
        });
        inFlightTransactionsStore.get = jest.fn(() => storedInFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('----|');
        const tip$ = hot<Cardano.Tip>('----|');
        const submitting$ = hot<OutgoingTx>('----|');
        const pending$ = hot<OutgoingTx>('----|');
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [incomingTx, storedInFlightTx]
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
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('---a|', {
          a: { slot: storedInFlightTx.blockHeader.slot, ...storedInFlightOutgoingTx }
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('ab-a|', {
          a: [],
          b: [storedInFlightOutgoingTx]
        });
        expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
        expectObservable(transactionsTracker.history$).toBe('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [storedInFlightTx, incomingTx]
        });
      });
      expect(inFlightTransactionsStore.set).toHaveBeenCalledTimes(2);
      expect(inFlightTransactionsStore.set).lastCalledWith([]);
    });

    it('removes tx from inFlight$ when loading with stored in-flight transaction that is already confirmed on-chain', () => {
      const txToBeConfirmed = queryTransactionsResult.pageResults[0];
      const txInFlight = { submittedAt: Cardano.Slot(1), ...toOutgoingTx(txToBeConfirmed) };

      createTestScheduler().run(({ hot, expectObservable }) => {
        const storedInFlight$ = hot<TxInFlight[]>('a----|', {
          a: [txInFlight]
        });
        inFlightTransactionsStore.get = jest.fn(() => storedInFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = hot<Cardano.Tip>('-----|');
        const submitting$ = hot<OutgoingTx>('-----|');
        const pending$ = hot<OutgoingTx>('-----|');
        // The key of this test is that the 1st emission of transactions source already
        // contains the transaction that we loaded from inFlightTransactionsStore
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('----a|', {
          a: [txToBeConfirmed]
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
        expectObservable(transactionsTracker.outgoing.onChain$).toBe('----a|', {
          a: { slot: txToBeConfirmed.blockHeader.slot, ...txInFlight }
        });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe('(ab)c|', {
          // before loading from store
          a: [],
          // after loading from store
          b: [txInFlight],
          // after seeing it on-chain
          c: []
        });
      });
    });

    it('inFlight mixed with submitting transactions are removed from store on successful transaction', async () => {
      const outgoingTx = toOutgoingTx(queryTransactionsResult.pageResults[0]);
      const storedInFlightTx: TxInFlight = {
        body: { validityInterval: {} } as Cardano.TxBody,
        cbor: dummyCbor,
        id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa'),
        submittedAt: Cardano.Slot(1)
      };
      const incomingTx = {
        blockHeader: { blockNo: Cardano.BlockNo(1_000_000) },
        body: { validityInterval: {} },
        // should remove storedInFlightTx from inFlight$ once discovered on-chain
        id: storedInFlightTx.id
      } as Cardano.HydratedTx;

      createTestScheduler().run(({ hot, expectObservable }) => {
        const storedInFlight$ = hot<TxInFlight[]>('-a|', {
          a: [storedInFlightTx]
        });
        inFlightTransactionsStore.get = jest.fn(() => storedInFlight$);
        inFlightTransactionsStore.set = jest.fn();

        const failedToSubmit$ = hot<FailedTx>('-----|');
        const tip$ = hot<Cardano.Tip>('-----|');
        const submitting$ = hot<OutgoingTx>('--a--|', { a: outgoingTx });
        const pending$ = hot<OutgoingTx>('-----|');
        const transactionsSource$ = hot<Cardano.HydratedTx[]>('a---b|', {
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
          c: [storedInFlightTx, outgoingTx],
          d: [outgoingTx]
        });
      });
      expect(inFlightTransactionsStore.set).toHaveBeenCalledTimes(3);
      expect(inFlightTransactionsStore.set).lastCalledWith([outgoingTx]);
    });
  });
});
