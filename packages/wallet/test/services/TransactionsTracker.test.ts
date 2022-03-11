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
import { createTestScheduler } from '../testScheduler';
import { firstValueFrom, of } from 'rxjs';
import { mockWalletProvider, queryTransactionsResult } from '../mocks';

describe('TransactionsTracker', () => {
  test('createAddressTransactionsProvider', async () => {
    const provider$ = createAddressTransactionsProvider(
      mockWalletProvider(), of([queryTransactionsResult[0].body.inputs[0].address]), { initialInterval: 1 }, of(300)
    );
    expect(await firstValueFrom(provider$)).toEqual(queryTransactionsResult);
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
        const failedToSubmit$ = hot<FailedTx>(              '----|');
        const tip$ = hot<Cardano.Tip>(                      '----|');
        const submitting$ = hot(                            '-a--|', { a: outgoingTx });
        const pending$ = hot(                               '--a-|', { a: outgoingTx });
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('a-bc|', {
          a: [],
          b: [incomingTx],
          c: [incomingTx, outgoingTx]
        });
        const confirmedSubscription =         '--^--'; // regression: subscribing after submitting$ emits
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
        expectObservable(transactionsTracker.incoming$).toBe(           '--a-|', { a: incomingTx });
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe(   '--a-|', { a: outgoingTx });
        expectObservable(
          transactionsTracker.outgoing.confirmed$,
          confirmedSubscription
        ).toBe(                                                         '---a|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe(  'ab-c|', { a: [], b: [outgoingTx], c: [] });
        expectObservable(transactionsTracker.outgoing.failed$).toBe(    '----|');
        expectObservable(transactionsTracker.history.incoming$).toBe(   'a-b-|', {
          a: [], b: [incomingTx]
        });
        expectObservable(transactionsTracker.history.outgoing$).toBe(   'a--b|', {
          a: [], b: [outgoingTx]
        });
        expectObservable(transactionsTracker.history.all$).toBe(        'a-bc|', {
          a: [],
          b: [{
            direction: TransactionDirection.Incoming, tx: incomingTx }
          ],
          c: [
            { direction: TransactionDirection.Incoming, tx: incomingTx },
            { direction: TransactionDirection.Outgoing, tx: outgoingTx }
          ]
        });
      });
    });

    it('emits at all relevant observable properties on timed out transaction', async () => {
      const tx = queryTransactionsResult[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const tip = { slot: tx.body.validityInterval.invalidHereafter! + 1 } as Cardano.Tip;
        const failedToSubmit$ = hot<FailedTx>(              '-----|');
        const tip$ = hot<Cardano.Tip>(                      '----a|', { a: tip });
        const submitting$ = hot(                            '-a---|', { a: tx });
        const pending$ = hot(                               '---a-|', { a: tx });
        const transactionsSource$ = hot<Cardano.TxAlonzo[]>('-----|');
        const failedSubscription =                          '--^---'; // regression: subscribing after submitting$ emits
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
        expectObservable(transactionsTracker.outgoing.submitting$).toBe(                '-a---|', { a: tx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe(                   '---a-|', { a: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe(                  'ab--c|', {
          a: [], b: [tx], c: []
        });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe(                 '-----|');
        expectObservable(transactionsTracker.outgoing.failed$, failedSubscription).toBe('----a|', {
          a: { reason: TransactionFailure.Timeout, tx }
        });
      });
    });

    it('emits at all relevant observable properties on transaction that failed to submit', async () => {
      const tx = queryTransactionsResult[0];
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const tip$ = hot<Cardano.Tip>(                        '----|');
        const submitting$ = cold(                             '-a--|', { a: tx });
        const pending$ = cold(                                '--a-|', { a: tx });
        const transactionsSource$ = cold<Cardano.TxAlonzo[]>( '----|');
        const failedToSubmit$ = hot<FailedTx>(                '---a|', {
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
        expectObservable(transactionsTracker.outgoing.pending$).toBe(   '--a-|', { a: tx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe(  'ab-c|', { a: [], b: [tx], c: [] });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe( '----|');
        expectObservable(transactionsTracker.outgoing.failed$).toBe(    '---a|', {
          a: { reason: TransactionFailure.FailedToSubmit, tx }
        });
      });
    });
  });
});
