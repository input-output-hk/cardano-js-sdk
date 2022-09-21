import { Cardano, calculateStabilityWindowSlotsCount } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, filter, from, map, merge, mergeMap, scan, tap, withLatestFrom } from 'rxjs';

import { CustomError } from 'ts-custom-error';
import { DocumentStore } from '../persistence';
import { NewTxAlonzoWithSlot, TransactionsTracker } from './types';

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
  transactions: Pick<TransactionsTracker, 'rollback$'> & {
    outgoing: Pick<TransactionsTracker['outgoing'], 'confirmed$' | 'submitting$'>;
  };
  store: DocumentStore<NewTxAlonzoWithSlot[]>;
  tipSlot$: Observable<Cardano.Slot>;
  genesisParameters$: Observable<Pick<Cardano.CompactGenesis, 'securityParameter' | 'activeSlotsCoefficient'>>;
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
    outgoing: { confirmed$, submitting$ }
  },
  store,
  tipSlot$,
  genesisParameters$,
  logger
}: TransactionReemitterProps): Observable<Cardano.NewTxAlonzo> => {
  const volatileTransactions$ = merge(
    store.get().pipe(
      tap((txs) => logger.debug(`Store contains ${txs.length} volatile transactions`)),
      mergeMap((txs) => from(txs)),
      map((tx) => ({ source: txSource.store, tx }))
    ),
    confirmed$.pipe(map((tx) => ({ source: txSource.confirmed, tx }))),
    submitting$.pipe(map((tx) => ({ source: txSource.submitting, tx: { ...tx, slot: null! } })))
  ).pipe(
    mergeMap((vt) =>
      genesisParameters$.pipe(
        map(({ securityParameter, activeSlotsCoefficient }) =>
          calculateStabilityWindowSlotsCount({ activeSlotsCoefficient, securityParameter })
        ),
        map((sw) => ({ sw, vt }))
      )
    ),
    scan((volatiles, { vt: { tx, source }, sw: stabilityWindowSlotsCount }) => {
      switch (source) {
        case txSource.store: {
          // Do not calculate stability window for old transactions coming from the store
          volatiles = [...volatiles, tx];
          break;
        }
        case txSource.submitting: {
          // Transactions in submitting are the ones reemitted. Remove them from volatiles
          logger.debug(`Transaction ${tx.id} is being resubmitted. Remove it from volatiles`);
          volatiles = volatiles.filter((v) => v.id !== tx.id);
          store.set(volatiles);
          break;
        }
        case txSource.confirmed: {
          const oldestAcceptedSlot = tx.slot > stabilityWindowSlotsCount ? tx.slot - stabilityWindowSlotsCount : 0;
          // Remove transactions considered stable
          logger.debug(`Removing stable transactions (slot <= ${oldestAcceptedSlot}), from volatiles`);
          logger.debug(`Adding new volatile transaction ${tx.id}`);
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
