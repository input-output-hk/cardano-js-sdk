import { Cardano, calculateStabilityWindowSlotsCount } from '@cardano-sdk/core';
import { combineLatest, filter, from, map, merge, mergeMap, partition, scan, share, tap, withLatestFrom } from 'rxjs';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';

import { TransactionFailure } from './types.js';
import { isNotNil } from '@cardano-sdk/util';
import pick from 'lodash/pick.js';
import type { FailedTx, Milliseconds, OutgoingOnChainTx, OutgoingTx, TransactionsTracker } from './types.js';
import type { WalletStores } from '../persistence/index.js';

export interface TransactionReemitterProps {
  transactions: Pick<TransactionsTracker, 'rollback$'> & {
    outgoing: Pick<TransactionsTracker['outgoing'], 'onChain$' | 'submitting$' | 'inFlight$'>;
  };
  stores: Pick<WalletStores, 'inFlightTransactions' | 'volatileTransactions'>;
  tipSlot$: Observable<Cardano.Slot>;
  genesisParameters$: Observable<
    Pick<Cardano.CompactGenesis, 'securityParameter' | 'activeSlotsCoefficient' | 'slotLength'>
  >;
  /**
   * It is possible that a transaction is rolled back before it is found on chain.
   * This option can be used to re-emit (and then attempt to re-submit) a transaction if it takes too long to show up on chain.
   */
  maxInterval: Milliseconds;
  logger: Logger;
}

export interface TransactionReemiter {
  reemit$: Observable<OutgoingTx>;
  failed$: Observable<FailedTx>;
}

enum txSource {
  store,
  onChain,
  submitting
}

export const createTransactionReemitter = ({
  transactions: {
    rollback$,
    outgoing: { onChain$, submitting$, inFlight$ }
  },
  stores,
  tipSlot$,
  maxInterval,
  genesisParameters$,
  logger
}: TransactionReemitterProps): TransactionReemiter => {
  const volatileTransactions$ = merge(
    stores.volatileTransactions.get().pipe(
      tap((txs) => logger.debug(`Store contains ${txs.length} volatile transactions`)),
      mergeMap((txs) => from(txs)),
      map((tx) => ({ source: txSource.store, tx } as const))
    ),
    onChain$.pipe(map((tx) => ({ onChain: tx, source: txSource.onChain } as const))),
    submitting$.pipe(map((tx) => ({ source: txSource.submitting, tx } as const)))
  ).pipe(
    mergeMap((vt) =>
      genesisParameters$.pipe(
        map(({ securityParameter, activeSlotsCoefficient }) =>
          calculateStabilityWindowSlotsCount({ activeSlotsCoefficient, securityParameter })
        ),
        map((sw) => ({ sw, vt }))
      )
    ),
    scan((volatiles, { vt, sw: stabilityWindowSlotsCount }) => {
      switch (vt.source) {
        case txSource.store: {
          // Do not calculate stability window for old transactions coming from the store
          volatiles = [...volatiles, vt.tx];
          break;
        }
        case txSource.submitting: {
          volatiles = volatiles.filter((tx) => {
            const isResubmittedTx = tx.id === vt.tx.id;
            if (isResubmittedTx) {
              // Volatile transactions in submitting are the ones reemitted. Remove them from volatiles
              logger.debug(`Transaction ${vt.tx.id} is being resubmitted. Remove it from volatiles`);
            }
            return !isResubmittedTx;
          });
          stores.volatileTransactions.set(volatiles);
          break;
        }
        case txSource.onChain: {
          const oldestAcceptedSlot =
            vt.onChain.slot > stabilityWindowSlotsCount ? vt.onChain.slot - stabilityWindowSlotsCount : 0;
          // Remove transactions considered stable
          logger.debug(`Removing stable transactions (slot <= ${oldestAcceptedSlot}), from volatiles`);
          logger.debug(`Adding new volatile transaction ${vt.onChain.id}`);
          volatiles = [...volatiles.filter(({ slot }) => slot > oldestAcceptedSlot), vt.onChain];
          stores.volatileTransactions.set(volatiles);
          break;
        }
      }
      return volatiles;
    }, [] as OutgoingOnChainTx[])
  );

  const rollbacks$ = rollback$.pipe(
    filter((tx) => !Cardano.util.isPhase2ValidationErrTx(tx)),
    withLatestFrom(volatileTransactions$),
    map(([tx, volatiles]) => {
      // Get the onChain Tx transaction to be retried
      const reemitTx = volatiles.find((txVolatile) => txVolatile.id === tx.id);
      if (!reemitTx) {
        logger.error(`Could not find onChain transaction with id ${tx.id} that was rolled back`);
        return;
      }
      return reemitTx!;
    }),
    filter(isNotNil),
    withLatestFrom(tipSlot$),
    map(([tx, tipSlot]) => {
      const invalidHereafter = tx.body?.validityInterval?.invalidHereafter;
      if (invalidHereafter && tipSlot > invalidHereafter) {
        const err: FailedTx = {
          reason: TransactionFailure.Timeout,
          ...tx
        };
        logger.error(`Rolled back transaction with id ${err.id} is no longer valid`, err.reason);
        return err;
      }
      return tx;
    }),
    share()
  );

  const [failed$, rollbackRetry$] = partition(rollbacks$, (v): v is FailedTx => (v as FailedTx).reason !== undefined);

  // If there are any transactions without `submittedAt` in store on load, it means that
  // wallet was shut down before transaction submission resolved.
  // Submission might have failed and could be retryable, so we should attempt to re-submit it.
  const unsubmitted$ = stores.inFlightTransactions.get().pipe(
    map((txs) => txs.filter(({ submittedAt }) => !submittedAt)),
    mergeMap((txs) => from(txs)),
    tap((tx) => logger.debug('Reemitting in-flight tx that was never submitted', tx.id))
  );

  const reemitSubmittedBefore$ = tipSlot$.pipe(
    withLatestFrom(genesisParameters$),
    map(([tip, { slotLength }]) => tip - maxInterval / (slotLength * 1000))
  );
  const reemitUnconfirmed$ = combineLatest([reemitSubmittedBefore$, inFlight$]).pipe(
    mergeMap(([reemitSubmittedBefore, inFlight]) =>
      from(inFlight.filter(({ submittedAt }) => submittedAt && submittedAt < reemitSubmittedBefore))
    ),
    tap((tx) => logger.debug('Reemitting unconfirmed in-flight tx', tx.id, 'submitted at slot', tx.submittedAt))
  );

  return {
    failed$,
    reemit$: merge(rollbackRetry$, unsubmitted$, reemitUnconfirmed$).pipe(
      map((tx) => pick(tx, ['cbor', 'body', 'id', 'context']))
    )
  };
};
