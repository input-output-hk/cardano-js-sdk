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
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Shutdown } from '@cardano-sdk/util';
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
}

export interface TransactionsTrackerInternals {
  transactionsSource$: Observable<Cardano.TxAlonzo[]>;
  rollback$: Observable<Cardano.TxAlonzo>;
}

export const createAddressTransactionsProvider = (
  chainHistoryProvider: ChainHistoryProvider,
  addresses$: Observable<Cardano.Address[]>,
  retryBackoffConfig: RetryBackoffConfig,
  tipBlockHeight$: Observable<number>,
  store: OrderedCollectionStore<Cardano.TxAlonzo>
): TransactionsTrackerInternals => {
  const rollback$ = new Subject<Cardano.TxAlonzo>();
  const storedTransactions$ = store.getAll().pipe(share());
  return {
    rollback$: rollback$.asObservable(),
    transactionsSource$: concat(
      storedTransactions$,
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
                const newTransactions = await chainHistoryProvider.transactionsByAddresses({
                  addresses,
                  sinceBlock: lastStoredTransaction?.blockHeader.blockNo
                });
                const duplicateTransactions =
                  lastStoredTransaction && intersectionBy(localTransactions, newTransactions, (tx) => tx.id);
                if (typeof duplicateTransactions !== 'undefined' && duplicateTransactions.length === 0) {
                  from(
                    localTransactions.filter(
                      ({ blockHeader: { blockNo } }) => blockNo >= lastStoredTransaction.blockHeader.blockNo
                    )
                  ).subscribe(rollback$);

                  // Rollback by 1 block, try again in next loop iteration
                  localTransactions = localTransactions.filter(
                    ({ blockHeader: { blockNo } }) => blockNo < lastStoredTransaction.blockHeader.blockNo
                  );
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
    inFlightTransactionsStore: newTransactionsStore
  }: TransactionsTrackerProps,
  { transactionsSource$: txSource$, rollback$ }: TransactionsTrackerInternals = createAddressTransactionsProvider(
    chainHistoryProvider,
    addresses$,
    retryBackoffConfig,
    distinctBlock(tip$),
    transactionsStore
  )
): TransactionsTracker & Shutdown => {
  const submitting$ = merge(
    newTransactionsStore.get().pipe(mergeMap((transactions) => from(transactions))),
    newSubmitting$
  ).pipe(share());

  const transactionsSource$ = new TrackerSubject(txSource$);

  const historicalTransactions$ = createHistoricalTransactionsTrackerSubject(transactionsSource$);
  const txConfirmed$ = (tx: Cardano.NewTxAlonzo): Observable<NewTxAlonzoWithSlot> =>
    newTransactions$(historicalTransactions$).pipe(
      filter((historyTx) => historyTx.id === tx.id),
      take(1),
      map((historyTx) => ({ ...tx, slot: historyTx.blockHeader.slot }))
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
      })
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
    }
  };
};
