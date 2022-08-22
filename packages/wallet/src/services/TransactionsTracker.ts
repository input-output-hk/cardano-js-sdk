import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { DocumentStore, OrderedCollectionStore } from '../persistence';
import {
  EMPTY,
  Observable,
  Subject,
  combineLatest,
  concat,
  defaultIfEmpty,
  exhaustMap,
  filter,
  from,
  map,
  merge,
  mergeMap,
  of,
  race,
  scan,
  share,
  startWith,
  switchMap,
  take,
  takeUntil,
  tap
} from 'rxjs';
import { FailedTx, NewTxAlonzoWithSlot, TransactionFailure, TransactionsTracker } from './types';
import { Logger } from 'ts-log';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Shutdown, contextLogger } from '@cardano-sdk/util';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { coldObservableProvider, distinctBlock, transactionsEquals } from './util';
import intersectionBy from 'lodash/intersectionBy';
import sortBy from 'lodash/sortBy';
import unionBy from 'lodash/unionBy';

export interface TransactionsTrackerProps {
  chainHistoryProvider: ChainHistoryProvider;
  addresses$: Observable<Cardano.Address[]>;
  tip$: Observable<Cardano.Tip>;
  retryBackoffConfig: RetryBackoffConfig;
  transactionsHistoryStore: OrderedCollectionStore<Cardano.TxAlonzo>;
  inFlightTransactionsStore: DocumentStore<Cardano.NewTxAlonzo[]>;
  newTransactions: {
    submitting$: Observable<Cardano.NewTxAlonzo>;
    pending$: Observable<Cardano.NewTxAlonzo>;
    failedToSubmit$: Observable<FailedTx>;
  };
  logger: Logger;
}

export interface TransactionsTrackerInternals {
  transactionsSource$: Observable<Cardano.TxAlonzo[]>;
  rollback$: Observable<Cardano.TxAlonzo>;
}

export interface TransactionsTrackerInternalsProps {
  chainHistoryProvider: ChainHistoryProvider;
  addresses$: Observable<Cardano.Address[]>;
  retryBackoffConfig: RetryBackoffConfig;
  tipBlockHeight$: Observable<number>;
  store: OrderedCollectionStore<Cardano.TxAlonzo>;
  logger: Logger;
}

export const createAddressTransactionsProvider = ({
  chainHistoryProvider,
  addresses$,
  retryBackoffConfig,
  tipBlockHeight$,
  store,
  logger
}: TransactionsTrackerInternalsProps): TransactionsTrackerInternals => {
  const rollback$ = new Subject<Cardano.TxAlonzo>();
  const storedTransactions$ = store.getAll().pipe(share());
  return {
    rollback$: rollback$.asObservable(),
    transactionsSource$: concat(
      storedTransactions$.pipe(
        tap((storedTransactions) =>
          logger.debug(`Stored history transactions count: ${storedTransactions?.length || 0}`)
        )
      ),
      combineLatest([addresses$, storedTransactions$.pipe(defaultIfEmpty([] as Cardano.TxAlonzo[]))]).pipe(
        switchMap(([addresses, storedTransactions]) => {
          let localTransactions: Cardano.TxAlonzo[] = [...storedTransactions];

          return coldObservableProvider({
            // Do not re-fetch transactions twice on load when tipBlockHeight$ loads from storage first
            // It should also help when using poor internet connection.
            // Caveat is that local transactions might get out of date...
            combinator: exhaustMap,
            equals: transactionsEquals,
            provider: async () => {
              // eslint-disable-next-line no-constant-condition
              while (true) {
                const lastStoredTransaction: Cardano.TxAlonzo | undefined =
                  localTransactions[localTransactions.length - 1];

                lastStoredTransaction &&
                  logger.debug(
                    `Last stored tx: ${lastStoredTransaction?.id} block:${lastStoredTransaction?.blockHeader.blockNo}`
                  );

                const sinceBlock = lastStoredTransaction?.blockHeader.blockNo;
                const newTransactions = await chainHistoryProvider.transactionsByAddresses({
                  addresses,
                  sinceBlock
                });
                logger.debug(
                  `chainHistoryProvider returned ${newTransactions.length} transactions`,
                  sinceBlock !== undefined && `since block ${sinceBlock}`
                );
                const duplicateTransactions =
                  lastStoredTransaction && intersectionBy(localTransactions, newTransactions, (tx) => tx.id);
                if (typeof duplicateTransactions !== 'undefined' && duplicateTransactions.length === 0) {
                  const rollbackTransactions = localTransactions.filter(
                    ({ blockHeader: { blockNo } }) => blockNo >= sinceBlock
                  );

                  from(rollbackTransactions)
                    .pipe(tap((tx) => logger.debug(`Transaction ${tx.id} was rolled back`)))
                    .subscribe((v) => rollback$.next(v));

                  // Rollback by 1 block, try again in next loop iteration
                  localTransactions = localTransactions.filter(({ blockHeader: { blockNo } }) => blockNo < sinceBlock);
                } else {
                  localTransactions = unionBy(localTransactions, newTransactions, (tx) => tx.id);
                  store.setAll(localTransactions);
                  return localTransactions;
                }
              }
            },
            retryBackoffConfig,
            trigger$: tipBlockHeight$
          });
        })
      )
    )
  };
};

const createHistoricalTransactionsTrackerSubject = (
  transactions$: Observable<Cardano.TxAlonzo[]>
): TrackerSubject<Cardano.TxAlonzo[]> =>
  new TrackerSubject(
    transactions$.pipe(
      map((transactions) =>
        sortBy(
          transactions,
          ({ blockHeader: { blockNo } }) => blockNo,
          ({ index }) => index
        )
      )
    )
  );

const newTransactions$ = (transactions$: Observable<Cardano.TxAlonzo[]>) =>
  transactions$.pipe(
    take(1),
    map((transactions) => transactions.map(({ id }) => id)),
    mergeMap((initialTransactionIds) => {
      const ignoredTransactionIds: Cardano.TransactionId[] = [...initialTransactionIds];
      return transactions$.pipe(
        map((transactions) => transactions.filter(({ id }) => !ignoredTransactionIds.includes(id))),
        tap((newTransactions) => ignoredTransactionIds.push(...newTransactions.map(({ id }) => id))),
        mergeMap((newTransactions) => concat(...newTransactions.map((tx) => of(tx))))
      );
    })
  );

export const createTransactionsTracker = (
  {
    tip$,
    chainHistoryProvider,
    addresses$,
    newTransactions: { submitting$: newSubmitting$, pending$, failedToSubmit$ },
    retryBackoffConfig,
    transactionsHistoryStore: transactionsStore,
    inFlightTransactionsStore: newTransactionsStore,
    logger
  }: TransactionsTrackerProps,
  { transactionsSource$: txSource$, rollback$ }: TransactionsTrackerInternals = createAddressTransactionsProvider({
    addresses$,
    chainHistoryProvider,
    logger: contextLogger(logger, 'AddressTransactionsProvider'),
    retryBackoffConfig,
    store: transactionsStore,
    tipBlockHeight$: distinctBlock(tip$)
  })
): TransactionsTracker & Shutdown => {
  const submitting$ = merge(
    newTransactionsStore.get().pipe(
      tap((transactions) => logger.debug(`Store contains ${transactions?.length} in flight transactions`)),
      mergeMap((transactions) => from(transactions))
    ),
    newSubmitting$.pipe(tap((newSubmitting) => logger.debug(`Got new submitting transaction: ${newSubmitting.id}`)))
  ).pipe(share());

  const transactionsSource$ = new TrackerSubject(txSource$);

  const historicalTransactions$ = createHistoricalTransactionsTrackerSubject(transactionsSource$);
  const txConfirmed$ = (tx: Cardano.NewTxAlonzo): Observable<NewTxAlonzoWithSlot> =>
    newTransactions$(historicalTransactions$).pipe(
      filter((historyTx) => historyTx.id === tx.id),
      take(1),
      map((historyTx) => ({ ...tx, slot: historyTx.blockHeader.slot })),
      tap((historyTx) => logger.debug(`Transaction ${historyTx.id} is confirmed in slot ${historyTx.slot}`))
    );

  const failed$ = new Subject<FailedTx>();
  const failedSubscription = submitting$
    .pipe(
      mergeMap((tx) => {
        const invalidHereafter = tx.body.validityInterval.invalidHereafter;
        return race(
          failedToSubmit$.pipe(
            filter((failed) => failed.tx === tx),
            take(1)
          ),
          invalidHereafter
            ? tip$.pipe(
                filter(({ slot }) => slot > invalidHereafter),
                map(() => ({ reason: TransactionFailure.Timeout, tx })),
                take(1)
              )
            : EMPTY
        ).pipe(takeUntil(txConfirmed$(tx)));
      }),
      tap((failed) => logger.debug(`Transaction ${failed.tx.id} failed`, failed.reason))
    )
    .subscribe(failed$);

  const txFailed$ = (tx: Cardano.NewTxAlonzo) =>
    failed$.pipe(
      filter((failed) => failed.tx === tx),
      take(1)
    );

  const inFlight$ = new TrackerSubject<Cardano.NewTxAlonzo[]>(
    submitting$.pipe(
      mergeMap((tx) =>
        merge(
          of({ op: 'add' as const, tx }),
          race(txConfirmed$(tx), txFailed$(tx)).pipe(map(() => ({ op: 'remove' as const, tx })))
        )
      ),
      scan((inFlight, { op, tx }) => {
        if (op === 'add') {
          return [...inFlight, tx];
        }
        const idx = inFlight.indexOf(tx);
        return [...inFlight.slice(0, idx), ...inFlight.slice(idx + 1)];
      }, [] as Cardano.NewTxAlonzo[]),
      tap((inFlight) => newTransactionsStore.set(inFlight)),
      tap((inFlight) => logger.debug(`${inFlight.length} in flight transactions`)),
      startWith([])
    )
  );

  const confirmed$ = new Subject<NewTxAlonzoWithSlot>();
  const confirmedSubscription = submitting$
    .pipe(mergeMap((tx) => txConfirmed$(tx).pipe(takeUntil(txFailed$(tx)))))
    .subscribe(confirmed$);

  return {
    history$: historicalTransactions$,
    outgoing: {
      confirmed$,
      failed$,
      inFlight$,
      pending$,
      submitting$
    },
    rollback$,
    shutdown: () => {
      inFlight$.complete();
      confirmedSubscription.unsubscribe();
      confirmed$.complete();
      failedSubscription.unsubscribe();
      failed$.complete();
      logger.debug('Shutdown');
    }
  };
};
