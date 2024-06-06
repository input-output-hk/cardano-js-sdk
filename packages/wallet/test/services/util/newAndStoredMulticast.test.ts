import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler, logger, mockProviders } from '@cardano-sdk/util-dev';

import { dummyCbor, toOutgoingTx } from '../../util.js';
import { mergeMap } from 'rxjs';
import { newAndStoredMulticast } from '../../../src/services/util/index.js';
import type { OutgoingTx, TxInFlight } from '../../../src/index.js';
const { generateTxAlonzo, queryTransactionsResult } = mockProviders;

describe('newAndStoredMulticast', () => {
  it('emit from new and stored', () => {
    const [outgoingTx] = generateTxAlonzo(1).map(toOutgoingTx);
    const storedInFlightTx: TxInFlight = {
      body: {} as Cardano.TxBody,
      cbor: dummyCbor,
      id: queryTransactionsResult.pageResults[0].id,
      submittedAt: Cardano.Slot(1)
    };

    createTestScheduler().run(({ hot, expectObservable }) => {
      const storedInFlight$ = hot<TxInFlight[]>('-a|', {
        a: [storedInFlightTx]
      });

      const submitting$ = hot<OutgoingTx>('a-|', {
        a: outgoingTx
      });
      const newAndStoredMulticast$ = newAndStoredMulticast<TxInFlight, Cardano.TransactionId>({
        groupByFn: (tx) => tx.id,
        logger,
        new$: submitting$,
        stored$: storedInFlight$
      }).pipe(mergeMap((signedTx$) => signedTx$));

      expectObservable(newAndStoredMulticast$).toBe('ab|', {
        a: outgoingTx,
        b: storedInFlightTx
      });
    });
  });

  it('filter stored unsubmitted transactions', () => {
    const [outgoingTx] = generateTxAlonzo(1).map(toOutgoingTx);
    const storedInFlightTx: TxInFlight = {
      body: {} as Cardano.TxBody,
      cbor: dummyCbor,
      id: queryTransactionsResult.pageResults[0].id
    };

    createTestScheduler().run(({ hot, expectObservable }) => {
      const storedInFlight$ = hot<TxInFlight[]>('-a|', {
        a: [storedInFlightTx]
      });

      const submitting$ = hot<OutgoingTx>('a-|', {
        a: outgoingTx
      });
      const newAndStoredMulticast$ = newAndStoredMulticast<TxInFlight, Cardano.TransactionId>({
        groupByFn: (tx) => tx.id,
        logger,
        new$: submitting$,
        stored$: storedInFlight$,
        storedFilterfn: ({ submittedAt }) => !!submittedAt
      }).pipe(mergeMap((signedTx$) => signedTx$));

      expectObservable(newAndStoredMulticast$).toBe('a-|', {
        a: outgoingTx
      });
    });
  });
});
