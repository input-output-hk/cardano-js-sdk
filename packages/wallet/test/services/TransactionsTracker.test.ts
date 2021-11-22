/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
/* eslint-disable prettier/prettier */
import { Cardano, WalletProvider } from '@cardano-sdk/core';
import {
  DirectionalTransaction,
  FailedTx,
  SyncableIntervalTrackerSubject,
  TrackerSubject,
  TransactionDirection,
  TransactionFailure,
  createAddressTransactionsProvider,
  createTransactionsTracker
} from '../../src';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { createTestScheduler } from '../testScheduler';
import { firstValueFrom, of } from 'rxjs';
import { mockWalletProvider, queryTransactionsResult } from '../mocks';

describe('TransactionsTracker', () => {
  test('createAddressTransactionsProvider', async () => {
    const provider$ = createAddressTransactionsProvider(
      mockWalletProvider(), of([queryTransactionsResult[0].body.inputs[0].address]), { initialInterval: 1 }, of(300)
    );
    expect(await firstValueFrom(provider$)).toEqual([
      { direction: TransactionDirection.Outgoing, tx: queryTransactionsResult[0] }
    ]);
  });

  describe('createTransactionsTracker', () => {
    // these variables are not relevant for tests, because
    // they're using mock transactionsSource$
    let retryBackoffConfig: RetryBackoffConfig;
    let walletProvider: WalletProvider;
    const addresses$ = of([queryTransactionsResult[0].body.inputs[0].address]);

    it('observable properties behave correctly on successful transaction', async () => {
      const outgoingTx = queryTransactionsResult[0];
      const incomingDirectionalTx = { direction: TransactionDirection.Incoming, tx: { ...outgoingTx, id: 'other-id' } };
      const outgoingDirectionalTx = { direction: TransactionDirection.Outgoing, tx: outgoingTx };
      createTestScheduler().run(({ hot, expectObservable }) => {
        const failedToSubmit$ = hot<FailedTx>('----|');
        const tip$ = hot<Cardano.Tip>(        '----|');
        const submitting$ = hot(              '-a--|', { a: outgoingTx });
        const pending$ = hot(                 '--a-|', { a: outgoingTx });
        const transactionsSource$ = hot(      'a-bc|', {
          a: [],
          b: [incomingDirectionalTx],
          c: [incomingDirectionalTx, outgoingDirectionalTx]
        }) as unknown as SyncableIntervalTrackerSubject<DirectionalTransaction[]>;
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
            tip$,
            walletProvider
          },
          {
            transactionsSource$
          }
        );
        expectObservable(transactionsTracker.incoming$).toBe(           '--a-|', { a: incomingDirectionalTx.tx });
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe(   '--a-|', { a: outgoingTx });
        expectObservable(
          transactionsTracker.outgoing.confirmed$,
          confirmedSubscription
        ).toBe(                                                         '---a|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.inFlight$).toBe(  'ab-c|', { a: [], b: [outgoingTx], c: [] });
        expectObservable(transactionsTracker.outgoing.failed$).toBe(    '----|');
        expectObservable(transactionsTracker.history.incoming$).toBe(   'a-b-|', {
          a: [], b: [incomingDirectionalTx.tx]
        });
        expectObservable(transactionsTracker.history.outgoing$).toBe(   'a--b|', {
          a: [], b: [outgoingDirectionalTx.tx]
        });
        expectObservable(transactionsTracker.history.all$).toBe(        'a-bc|', {
          a: [], b: [incomingDirectionalTx], c: [incomingDirectionalTx, outgoingDirectionalTx]
        });
      });
    });

    it('emits at all relevant observable properties on timed out transaction', async () => {
      const tx = queryTransactionsResult[0];
      createTestScheduler().run(({ hot, expectObservable }) => {
        const tip = { slot: tx.body.validityInterval.invalidHereafter! + 1 } as Cardano.Tip;
        const failedToSubmit$ = hot<FailedTx>(  '-----|');
        const tip$ = hot<Cardano.Tip>(          '----a|', { a: tip });
        const submitting$ = hot(                '-a---|', { a: tx });
        const pending$ = hot(                   '---a-|', { a: tx });
        const transactionsSource$ = hot(        '-----|') as unknown as TrackerSubject<DirectionalTransaction[]>;
        const failedSubscription =              '--^---'; // regression: subscribing after submitting$ emits
        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
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
        const failedToSubmit$ = hot<FailedTx>('---a|', { a: { reason: TransactionFailure.FailedToSubmit, tx } });
        const tip$ = hot<Cardano.Tip>(        '----|');
        const submitting$ = cold(             '-a--|', { a: tx });
        const pending$ = cold(                '--a-|', { a: tx });
        const transactionsSource$ = cold(     '----|') as unknown as TrackerSubject<DirectionalTransaction[]>;
        const transactionsTracker = createTransactionsTracker(
          {
            addresses$,
            newTransactions: {
              failedToSubmit$,
              pending$,
              submitting$
            },
            retryBackoffConfig,
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
