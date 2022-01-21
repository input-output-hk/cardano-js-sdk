import { Cardano, WalletProvider } from '@cardano-sdk/core';
import {
  DirectionalTransaction,
  FailedTx,
  TransactionDirection,
  TransactionFailure,
  TransactionsTracker
} from './types';
import {
  EMPTY,
  Observable,
  Subject,
  concat,
  distinctUntilChanged,
  filter,
  map,
  merge,
  mergeMap,
  of,
  race,
  scan,
  startWith,
  switchMap,
  take,
  takeUntil,
  tap
} from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackerSubject } from './util/TrackerSubject';
import { coldObservableProvider, distinctBlock, transactionsEquals } from './util';
import { sortBy } from 'lodash-es';

export interface TransactionsTrackerProps {
  walletProvider: WalletProvider;
  addresses$: Observable<Cardano.Address[]>;
  tip$: Observable<Cardano.Tip>;
  retryBackoffConfig: RetryBackoffConfig;
  newTransactions: {
    submitting$: Observable<Cardano.NewTxAlonzo>;
    pending$: Observable<Cardano.NewTxAlonzo>;
    failedToSubmit$: Observable<FailedTx>;
  };
}

export interface TransactionsTrackerInternals {
  transactionsSource$?: TrackerSubject<DirectionalTransaction[]>;
}

export const createAddressTransactionsProvider = (
  walletProvider: WalletProvider,
  addresses$: Observable<Cardano.Address[]>,
  retryBackoffConfig: RetryBackoffConfig,
  tipBlockHeight$: Observable<number>
): Observable<DirectionalTransaction[]> => {
  const isMyAddress =
    (addresses: Cardano.Address[]) =>
    ({ address }: { address: Cardano.Address }) =>
      addresses.includes(address);
  return addresses$.pipe(
    switchMap((addresses) =>
      coldObservableProvider(
        () => walletProvider.queryTransactionsByAddresses(addresses),
        retryBackoffConfig,
        tipBlockHeight$,
        transactionsEquals
      ).pipe(
        map((transactions) =>
          sortBy(
            transactions,
            ({ blockHeader: { blockNo } }) => blockNo,
            ({ index }) => index
          ).map((tx) => {
            const direction = tx.body.inputs.some(isMyAddress(addresses))
              ? TransactionDirection.Outgoing
              : TransactionDirection.Incoming;
            return { direction, tx };
          })
        )
      )
    )
  );
};

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
    walletProvider,
    addresses$,
    newTransactions: { submitting$, pending$, failedToSubmit$ },
    retryBackoffConfig
  }: TransactionsTrackerProps,
  {
    transactionsSource$ = new TrackerSubject(
      createAddressTransactionsProvider(walletProvider, addresses$, retryBackoffConfig, distinctBlock(tip$))
    )
  }: TransactionsTrackerInternals = {}
): TransactionsTracker => {
  const providerTransactionsByDirection$ = (direction: TransactionDirection) =>
    transactionsSource$.pipe(
      map((transactions) => transactions.filter((tx) => tx.direction === direction).map(({ tx }) => tx)),
      distinctUntilChanged(transactionsEquals)
    );
  const incomingTransactionHistory$ = new TrackerSubject<Cardano.TxAlonzo[]>(
    providerTransactionsByDirection$(TransactionDirection.Incoming)
  );
  const outgoingTransactionHistory$ = new TrackerSubject<Cardano.TxAlonzo[]>(
    providerTransactionsByDirection$(TransactionDirection.Outgoing)
  );

  const txConfirmed$ = (tx: Cardano.NewTxAlonzo) =>
    newTransactions$(outgoingTransactionHistory$).pipe(
      filter((historyTx) => historyTx.id === tx.id),
      take(1),
      map(() => tx)
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
        return [...inFlight.splice(0, idx), ...inFlight.splice(idx + 1)];
      }, [] as Cardano.NewTxAlonzo[]),
      startWith([])
    )
  );

  const confirmed$ = new Subject<Cardano.NewTxAlonzo>();
  const confirmedSubscription = submitting$
    .pipe(mergeMap((tx) => txConfirmed$(tx).pipe(takeUntil(txFailed$(tx)))))
    .subscribe(confirmed$);

  return {
    history: {
      all$: transactionsSource$,
      incoming$: incomingTransactionHistory$,
      outgoing$: outgoingTransactionHistory$
    },
    incoming$: newTransactions$(incomingTransactionHistory$),
    outgoing: {
      confirmed$,
      failed$,
      inFlight$,
      pending$,
      submitting$
    },
    shutdown: () => {
      transactionsSource$.complete();
      inFlight$.complete();
      confirmedSubscription.unsubscribe();
      confirmed$.complete();
      failedSubscription.unsubscribe();
      failed$.complete();
    }
  };
};
