/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
/* eslint-disable prettier/prettier */
import { Cardano } from '@cardano-sdk/core';
import {
  DirectionalTransaction,
  FailedTx,
  ProviderTrackerSubject,
  SimpleProvider,
  SourceTrackerConfig,
  TransactionDirection,
  TransactionFailure,
  createTransactionsTracker
} from '../../src';
import { createTestScheduler } from '../testScheduler';
import { queryTransactionsResult } from '../mocks';

describe('createTransactionsTracker', () => {
  // both of these variables are not relevant for tests, because
  // they're using mock transactionsSource$
  let config: SourceTrackerConfig;
  let transactionsProvider: SimpleProvider<DirectionalTransaction[]>;

  it('observable properties behave correctly on successful transaction', async () => {
    const tx = queryTransactionsResult[0];
    const incomingTx = { direction: TransactionDirection.Incoming, tx };
    const outgoingTx = { direction: TransactionDirection.Outgoing, tx };
    createTestScheduler().run(({ cold, expectObservable }) => {
      const failedToSubmit$ = cold<FailedTx>( '----|');
      const tip$ = cold<Cardano.Tip>(         '----|');
      const submitting$ = cold(               '-a--|', { a: tx });
      const pending$ = cold(                  '--a-|', { a: tx });
      const transactionsSource$ = cold(       'a-bc|', {
        a: [],
        b: [incomingTx],
        c: [incomingTx, outgoingTx]
      }) as unknown as ProviderTrackerSubject<DirectionalTransaction[]>;
      const transactionsTracker = createTransactionsTracker(
        {
          config,
          newTransactions: {
            failedToSubmit$,
            pending$,
            submitting$
          },
          tip$,
          transactionsProvider
        },
        {
          transactionsSource$
        }
      );
      expectObservable(transactionsTracker.incoming$).toBe(           '--a-|', { a: incomingTx.tx });
      expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: tx });
      expectObservable(transactionsTracker.outgoing.pending$).toBe(   '--a-|', { a: tx });
      expectObservable(transactionsTracker.outgoing.confirmed$).toBe( '---a|', { a: tx });
      expectObservable(transactionsTracker.outgoing.inFlight$).toBe(  'ab-c|', { a: [], b: [tx], c: [] });
      expectObservable(transactionsTracker.outgoing.failed$).toBe(    '----|');
      expectObservable(transactionsTracker.history.incoming$).toBe(   'a-b-|', { a: [], b: [incomingTx.tx] });
      expectObservable(transactionsTracker.history.outgoing$).toBe(   'a--b|', { a: [], b: [outgoingTx.tx] });
      expectObservable(transactionsTracker.history.all$).toBe(        'a-bc|', {
        a: [], b: [incomingTx], c: [incomingTx, outgoingTx]
      });
    });
  });

  it('emits at all relevant observable properties on timed out transaction', async () => {
    const tx = queryTransactionsResult[0];
    createTestScheduler().run(({ cold, hot, expectObservable }) => {
      const tip = { slot: tx.body.validityInterval.invalidHereafter! + 1 } as Cardano.Tip;
      const failedToSubmit$ = cold<FailedTx>( '----|');
      const tip$ = hot<Cardano.Tip>(          '---a|', { a: tip });
      const submitting$ = cold(               '-a--|', { a: tx });
      const pending$ = cold(                  '--a-|', { a: tx });
      const transactionsSource$ = cold(       '----|') as unknown as ProviderTrackerSubject<DirectionalTransaction[]>;
      const transactionsTracker = createTransactionsTracker(
        {
          config,
          newTransactions: {
            failedToSubmit$,
            pending$,
            submitting$
          },
          tip$,
          transactionsProvider
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
      const transactionsSource$ = cold(     '----|') as unknown as ProviderTrackerSubject<DirectionalTransaction[]>;
      const transactionsTracker = createTransactionsTracker(
        {
          config,
          newTransactions: {
            failedToSubmit$,
            pending$,
            submitting$
          },
          tip$,
          transactionsProvider
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
