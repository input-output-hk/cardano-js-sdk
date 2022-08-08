import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, filter, from, map, merge, mergeMap, scan, withLatestFrom } from 'rxjs';

import { CustomError } from 'ts-custom-error';
import { DocumentStore } from '../persistence';
import { NewTxAlonzoWithSlot } from './types';

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

interface TransactionReemitterProps {
  rollback$: Observable<Cardano.TxAlonzo>;
  confirmed$: Observable<NewTxAlonzoWithSlot>;
  submitting$: Observable<Cardano.NewTxAlonzo>;
  store: DocumentStore<NewTxAlonzoWithSlot[]>;
  tipSlot$: Observable<Cardano.Slot>;
  stabilityWindowSlotsCount?: number;
  logger: Logger;
}

enum txSource {
  store,
  confirmed,
  submitting
}

// 3k/f (where k is the security parameter in genesis, and f is the active slot co-efficient parameter
// in genesis that determines the probability for amount of blocks created in an epoch.)
const kStabilityWindowSlotsCount = 129_600; // 3k/f on current mainnet

export const createTransactionReemitter = ({
  rollback$,
  confirmed$,
  submitting$,
  store,
  tipSlot$,
  stabilityWindowSlotsCount = kStabilityWindowSlotsCount,
  logger
}: TransactionReemitterProps): Observable<Cardano.NewTxAlonzo> => {
  const volatileTransactions$ = merge(
    store.get().pipe(
      mergeMap((txs) => from(txs)),
      map((tx) => ({ source: txSource.store, tx }))
    ),
    confirmed$.pipe(map((tx) => ({ source: txSource.confirmed, tx }))),
    submitting$.pipe(map((tx) => ({ source: txSource.submitting, tx: { ...tx, slot: null! } })))
  ).pipe(
    scan((volatiles, { tx, source }) => {
      switch (source) {
        case txSource.store: {
          // Do not calculate stability window for old transactions coming from the store
          volatiles = [...volatiles, tx];
          break;
        }
        case txSource.submitting: {
          // Transactions in submitting are the ones reemitted. Remove them from volatiles
          volatiles = volatiles.filter((v) => v.id !== tx.id);
          store.set(volatiles);
          break;
        }
        case txSource.confirmed: {
          const oldestAcceptedSlot = tx.slot > stabilityWindowSlotsCount ? tx.slot - stabilityWindowSlotsCount : 0;
          // Remove transactions considered stable
          volatiles = [...volatiles.filter(({ slot }) => slot > oldestAcceptedSlot), tx];
          store.set(volatiles);
          break;
        }
      }
      return volatiles;
    }, [] as NewTxAlonzoWithSlot[])
  );

  return rollback$.pipe(
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
      // Get the confirmed NewTxAlonzo transaction to be retried
      const reemitTx = volatiles.find((txVolatile) => txVolatile.id === tx!.id);
      if (!reemitTx) {
        const err = new TransactionReemitError(
          TransactionReemitErrorCode.notFound,
          `Could not find confirmed transaction with id ${tx!.id} that was rolled back`
        );
        logger.error(err.message, err.code);
      }
      return reemitTx!;
    }),
    filter((tx) => !!tx)
  );
};
