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

describe('TransactionsTracker', () => {
  describe('createAddressTransactionsProvider', () => {
    it.todo('queries underlying provider and emits sorted directional transactions');
  });

  describe('createTransactionsTracker', () => {
    // both of these variables are not relevant for tests, because
    // they're using mock transactionsSource$
    let config: SourceTrackerConfig;
    let transactionsProvider: SimpleProvider<DirectionalTransaction[]>;

    it('observable properties behave correctly on successful transaction', async () => {
      const outgoingTx = queryTransactionsResult[0];
      const incomingDirectionalTx = { direction: TransactionDirection.Incoming, tx: { ...outgoingTx, id: 'other-id' } };
      const outgoingDirectionalTx = { direction: TransactionDirection.Outgoing, tx: outgoingTx };
      createTestScheduler().run(({ cold, expectObservable }) => {
        const failedToSubmit$ = cold<FailedTx>( '----|');
        const tip$ = cold<Cardano.Tip>(         '----|');
        const submitting$ = cold(               '-a--|', { a: outgoingTx });
        const pending$ = cold(                  '--a-|', { a: outgoingTx });
        const transactionsSource$ = cold(       'a-bc|', {
          a: [],
          b: [incomingDirectionalTx],
          c: [incomingDirectionalTx, outgoingDirectionalTx]
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
        expectObservable(transactionsTracker.incoming$).toBe(           '--a-|', { a: incomingDirectionalTx.tx });
        expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.pending$).toBe(   '--a-|', { a: outgoingTx });
        expectObservable(transactionsTracker.outgoing.confirmed$).toBe( '---a|', { a: outgoingTx });
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
  });
