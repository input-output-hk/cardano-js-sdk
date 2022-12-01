import { Cardano, calculateStabilityWindowSlotsCount } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, combineLatest, filter, from, map, merge, mergeMap, scan, tap, withLatestFrom } from 'rxjs';

import { ConfirmedTx, Milliseconds, TransactionsTracker } from './types';
import { CustomError } from 'ts-custom-error';
import { WalletStores } from '../persistence';
import { isNotNil } from '@cardano-sdk/util';

export enum TransactionReemitErrorCode {
  invalidHereafter = 'invalidHereafter',
  notFound = 'notFound'
}
class TransactionReemitError extends CustomError {
  code: TransactionReemitErrorCode;
  public constructor(code: TransactionReemitErrorCode, message: string) {
    super(message);
    this.code = code;
  }
}

export interface TransactionReemitterProps {
  transactions: Pick<TransactionsTracker, 'rollback$'> & {
    outgoing: Pick<TransactionsTracker['outgoing'], 'confirmed$' | 'submitting$' | 'inFlight$'>;
  };
  stores: Pick<WalletStores, 'inFlightTransactions' | 'volatileTransactions'>;
  tipSlot$: Observable<Cardano.Slot>;
  genesisParameters$: Observable<
    Pick<Cardano.CompactGenesis, 'securityParameter' | 'activeSlotsCoefficient' | 'slotLength'>
  >;
  /**
   * It is possible that a transaction is rolled back before it is confirmed by showing up in transaction history.
   * This option can be used to re-emit (and then attempt to re-submit) a transaction if it takes too long to confirm.
   */
  maxInterval: Milliseconds;
  logger: Logger;
}

enum txSource {
  store,
  confirmed,
  submitting
}

export const createTransactionReemitter = ({
  transactions: {
    rollback$,
    outgoing: { confirmed$, submitting$, inFlight$ }
  },
  stores,
  tipSlot$,
  maxInterval,
  genesisParameters$,
  logger
}: TransactionReemitterProps): Observable<Cardano.Tx> => {
  const volatileTransactions$ = merge(
    stores.volatileTransactions.get().pipe(
      tap((txs) => logger.debug(`Store contains ${txs.length} volatile transactions`)),
      mergeMap((txs) => from(txs)),
      map((tx) => ({ source: txSource.store, tx } as const))
    ),
    confirmed$.pipe(map((tx) => ({ confirmed: tx, source: txSource.confirmed } as const))),
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
          // Transactions in submitting are the ones reemitted. Remove them from volatiles
          logger.debug(`Transaction ${vt.tx.id} is being resubmitted. Remove it from volatiles`);
          volatiles = volatiles.filter(({ tx }) => tx.id !== vt.tx.id);
          stores.volatileTransactions.set(volatiles);
          break;
        }
        case txSource.confirmed: {
          const oldestAcceptedSlot =
            vt.confirmed.confirmedAt > stabilityWindowSlotsCount
              ? vt.confirmed.confirmedAt - stabilityWindowSlotsCount
              : 0;
          // Remove transactions considered stable
          logger.debug(`Removing stable transactions (slot <= ${oldestAcceptedSlot}), from volatiles`);
          logger.debug(`Adding new volatile transaction ${vt.confirmed.tx.id}`);
          volatiles = [...volatiles.filter(({ confirmedAt }) => confirmedAt > oldestAcceptedSlot), vt.confirmed];
          stores.volatileTransactions.set(volatiles);
          break;
        }
      }
      return volatiles;
    }, [] as ConfirmedTx[])
  );

  const rollbacks$ = rollback$.pipe(
    withLatestFrom(tipSlot$),
    map(([tx, tipSlot]) => {
      const invalidHereafter = tx.body?.validityInterval?.invalidHereafter;
      if (invalidHereafter && tipSlot > invalidHereafter) {
        const err = new TransactionReemitError(
          TransactionReemitErrorCode.invalidHereafter,
          `Rolled back transaction with id ${tx.id} is no longer valid`
        );
        logger.error(err.message, err.code);
        return;
      }
      return tx;
    }),
    filter((tx) => !!tx),
    withLatestFrom(volatileTransactions$),
    map(([tx, volatiles]) => {
      // Get the confirmed Tx transaction to be retried
      const reemitTx = volatiles.find(({ tx: txVolatile }) => txVolatile.id === tx!.id);
      if (!reemitTx) {
        const err = new TransactionReemitError(
          TransactionReemitErrorCode.notFound,
          `Could not find confirmed transaction with id ${tx!.id} that was rolled back`
        );
        logger.error(err.message, err.code);
      }
      return reemitTx!;
    }),
    filter(isNotNil),
    map(({ tx }) => tx)
  );

  // If there are any transactions without `submittedAt` in store on load, it means that
  // wallet was shut down before transaction submission resolved.
  // Submission might have failed and could be retryable, so we should attempt to re-submit it.
  const unsubmitted$ = stores.inFlightTransactions.get().pipe(
    map((txs) => txs.filter(({ submittedAt }) => !submittedAt).map(({ tx }) => tx)),
    mergeMap((txs) => from(txs))
  );

  const reemitSubmittedBefore$ = tipSlot$.pipe(
    withLatestFrom(genesisParameters$),
    map(([tip, { slotLength }]) => tip - maxInterval / (slotLength * 1000))
  );
  const reemitUnconfirmed$ = combineLatest([reemitSubmittedBefore$, inFlight$]).pipe(
    mergeMap(([reemitSubmittedBefore, inFlight]) =>
      from(inFlight.filter(({ submittedAt }) => submittedAt && submittedAt < reemitSubmittedBefore).map(({ tx }) => tx))
    )
  );

  return merge(rollbacks$, unsubmitted$, reemitUnconfirmed$);
};
