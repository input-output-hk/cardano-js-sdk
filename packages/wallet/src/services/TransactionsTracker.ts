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
  combineLatest,
  concat,
  defaultIfEmpty,
  distinctUntilChanged,
  filter,
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
import { OrderedCollectionStore } from '../persistence';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackerSubject } from './util/TrackerSubject';
import { coldObservableProvider, distinctBlock, transactionsEquals } from './util';
import { intersectionBy, sortBy, unionBy } from 'lodash-es';

export interface TransactionsTrackerProps {
  walletProvider: WalletProvider;
  addresses$: Observable<Cardano.Address[]>;
  tip$: Observable<Cardano.Tip>;
  retryBackoffConfig: RetryBackoffConfig;
  store: OrderedCollectionStore<Cardano.TxAlonzo>;
  newTransactions: {
    submitting$: Observable<Cardano.NewTxAlonzo>;
    pending$: Observable<Cardano.NewTxAlonzo>;
    failedToSubmit$: Observable<FailedTx>;
  };
}

export interface TransactionsTrackerInternals {
  transactionsSource$?: Observable<Cardano.TxAlonzo[]>;
}

export const createAddressTransactionsProvider = (
  walletProvider: WalletProvider,
  addresses$: Observable<Cardano.Address[]>,
  retryBackoffConfig: RetryBackoffConfig,
  tipBlockHeight$: Observable<number>,
  store: OrderedCollectionStore<Cardano.TxAlonzo>
): Observable<Cardano.TxAlonzo[]> => {
  const storedTransactions$ = store.getAll().pipe(share());
  return concat(
    storedTransactions$,
    combineLatest([addresses$, storedTransactions$.pipe(defaultIfEmpty([] as Cardano.TxAlonzo[]))]).pipe(
      switchMap(([addresses, storedTransactions]) => {
        let localTransactions = [...storedTransactions];
        return coldObservableProvider(
          async () => {
            // eslint-disable-next-line no-constant-condition
            while (true) {
              const lastStoredTransaction: Cardano.TxAlonzo | undefined =
                localTransactions[localTransactions.length - 1];
              const newTransactions = await walletProvider.queryTransactionsByAddresses(
                addresses,
                lastStoredTransaction?.blockHeader.blockNo
              );
              const duplicateTransactions =
                lastStoredTransaction && intersectionBy(localTransactions, newTransactions, (tx) => tx.id);
              if (typeof duplicateTransactions !== 'undefined' && duplicateTransactions.length === 0) {
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
          tipBlockHeight$,
          transactionsEquals
        );
      })
    )
  );
};

const createDirectionalTransactionsTrackerSubject = (
  transactions$: Observable<Cardano.TxAlonzo[]>,
  addresses$: Observable<Cardano.Address[]>
): TrackerSubject<DirectionalTransaction[]> => {
  const isMyAddress =
    (addresses: Cardano.Address[]) =>
    ({ address }: { address: Cardano.Address }) =>
      addresses.includes(address);
  return new TrackerSubject(
    combineLatest([transactions$, addresses$]).pipe(
      map(([transactions, addresses]) =>
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
    retryBackoffConfig,
    store
  }: TransactionsTrackerProps,
  {
    transactionsSource$ = new TrackerSubject<Cardano.TxAlonzo[]>(
      createAddressTransactionsProvider(walletProvider, addresses$, retryBackoffConfig, distinctBlock(tip$), store)
    )
  }: TransactionsTrackerInternals = {}
): TransactionsTracker => {
  const directionalTransactions$ = createDirectionalTransactionsTrackerSubject(transactionsSource$, addresses$);
  const providerTransactionsByDirection$ = (direction: TransactionDirection) =>
    directionalTransactions$.pipe(
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
      all$: directionalTransactions$,
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
      directionalTransactions$.complete();
      inFlight$.complete();
      confirmedSubscription.unsubscribe();
      confirmed$.complete();
      failedSubscription.unsubscribe();
      failed$.complete();
    }
  };
};
