import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { DirectionalTransaction, FailedTx, TransactionDirection, Transactions } from './types';
import {
  EMPTY,
  Observable,
  concat,
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
  take,
  takeUntil,
  tap
} from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackerSubject } from './util/TrackerSubject';
import { TransactionFailure } from './TransactionError';
import { coldObservableProvider, sharedDistinctBlock, transactionsEquals } from './util';
import { flatten, sortBy } from 'lodash-es';

export interface TransactionsTrackerProps {
  walletProvider: WalletProvider;
  addresses: Cardano.Address[];
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
  addresses: Cardano.Address[],
  retryBackoffConfig: RetryBackoffConfig,
  tipBlockHeight$: Observable<number>
): Observable<DirectionalTransaction[]> => {
  const isMyAddress = ({ address }: { address: Cardano.Address }) => addresses.includes(address);
  return coldObservableProvider(
    () => walletProvider.queryTransactionsByAddresses(addresses),
    retryBackoffConfig,
    tipBlockHeight$,
    transactionsEquals
  ).pipe(
    map((transactions) =>
      flatten(
        sortBy(
          transactions,
          ({ blockHeader: { blockHeight } }) => blockHeight,
          ({ index }) => index
        ).map((tx) => {
          const {
            body: { inputs, outputs }
          } = tx;
          const incoming = outputs.some(isMyAddress) ? [{ direction: TransactionDirection.Incoming, tx }] : [];
          const outgoing = inputs.some(isMyAddress) ? [{ direction: TransactionDirection.Outgoing, tx }] : [];
          return [...incoming, ...outgoing];
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
      const ignoredTransactionIds: Cardano.Hash16[] = [...initialTransactionIds];
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
    addresses,
    newTransactions: { submitting$, pending$, failedToSubmit$ },
    retryBackoffConfig
  }: TransactionsTrackerProps,
  {
    transactionsSource$ = new TrackerSubject(
      createAddressTransactionsProvider(walletProvider, addresses, retryBackoffConfig, sharedDistinctBlock(tip$))
    )
  }: TransactionsTrackerInternals = {}
): Transactions => {
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

  const failed$: Observable<FailedTx> = submitting$.pipe(
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
    share()
  );

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

  return {
    history: {
      all$: transactionsSource$,
      incoming$: incomingTransactionHistory$,
      outgoing$: outgoingTransactionHistory$
    },
    incoming$: newTransactions$(incomingTransactionHistory$),
    outgoing: {
      confirmed$: submitting$.pipe(mergeMap((tx) => txConfirmed$(tx).pipe(takeUntil(txFailed$(tx))))),
      failed$,
      inFlight$,
      pending$,
      submitting$
    },
    shutdown: () => {
      transactionsSource$.complete();
      inFlight$.complete();
    }
  };
};
