import { Cardano, ChainHistoryProvider, Range } from '@cardano-sdk/core';
import { ConfirmedTx, FailedTx, TransactionFailure, TransactionsTracker, TxInFlight } from './types';
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
  groupBy,
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
  tap,
  withLatestFrom
} from 'rxjs';
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
  inFlightTransactionsStore: DocumentStore<TxInFlight[]>;
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

// Temporarily hardcoded. Will be replaced with ChainHistoryProvider 'maxPageSize' value once ADP-2249 is implemented
export const PAGE_SIZE = 25;

const allTransactionsByAddresses = async (
  chainHistoryProvider: ChainHistoryProvider,
  { addresses, blockRange }: { addresses: Cardano.Address[]; blockRange: Range<Cardano.BlockNo> }
): Promise<Cardano.TxAlonzo[]> => {
  let startAt = 0;
  let response: Cardano.TxAlonzo[] = [];
  let pageResults: Cardano.TxAlonzo[] = [];
  do {
    pageResults = (
      await chainHistoryProvider.transactionsByAddresses({
        addresses,
        blockRange,
        pagination: { limit: PAGE_SIZE, startAt }
      })
    ).pageResults;

    startAt += PAGE_SIZE;
    response = [...response, ...pageResults];
  } while (pageResults.length === PAGE_SIZE);
  return response;
};

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

                const lowerBound = lastStoredTransaction?.blockHeader.blockNo;
                const newTransactions = await allTransactionsByAddresses(chainHistoryProvider, {
                  addresses,
                  blockRange: { lowerBound }
                });

                logger.debug(
                  `chainHistoryProvider returned ${newTransactions.length} transactions`,
                  lowerBound !== undefined && `since block ${lowerBound}`
                );
                const duplicateTransactions =
                  lastStoredTransaction && intersectionBy(localTransactions, newTransactions, (tx) => tx.id);
                if (typeof duplicateTransactions !== 'undefined' && duplicateTransactions.length === 0) {
                  const rollbackTransactions = localTransactions.filter(
                    ({ blockHeader: { blockNo } }) => blockNo >= lowerBound
                  );

                  from(rollbackTransactions)
                    .pipe(tap((tx) => logger.debug(`Transaction ${tx.id} was rolled back`)))
                    .subscribe((v) => rollback$.next(v));

                  // Rollback by 1 block, try again in next loop iteration
                  localTransactions = localTransactions.filter(({ blockHeader: { blockNo } }) => blockNo < lowerBound);
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
  const submitting$ = newSubmitting$.pipe(
    tap((newSubmitting) => logger.debug(`Got new submitting transaction: ${newSubmitting.id}`)),
    share()
  );

  const transactionsSource$ = new TrackerSubject(txSource$);

  const historicalTransactions$ = createHistoricalTransactionsTrackerSubject(transactionsSource$);
  const txConfirmed$ = (tx: Cardano.NewTxAlonzo): Observable<ConfirmedTx> =>
    newTransactions$(historicalTransactions$).pipe(
      filter((historyTx) => historyTx.id === tx.id),
      take(1),
      map((historyTx) => ({ confirmedAt: historyTx.blockHeader.slot, tx })),
      tap(({ confirmedAt }) => logger.debug(`Transaction ${tx.id} is confirmed in slot ${confirmedAt}`))
    );

  const submittingOrPreviouslySubmitted$ = merge<TxInFlight[]>(
    submitting$.pipe(map((tx) => ({ tx }))),
    newTransactionsStore.get().pipe(
      tap((transactions) => logger.debug(`Store contains ${transactions?.length} in flight transactions`)),
      map((transactions) => transactions.filter(({ submittedAt }) => !!submittedAt)),
      mergeMap((transactions) => from(transactions))
    )
  ).pipe(
    // Tx could be re-submitted, so we group by tx id
    groupBy(({ tx: { id } }) => id),
    map((group$) => group$.pipe(share())),
    share()
  );

  const failed$ = new Subject<FailedTx>();
  const failedSubscription = submittingOrPreviouslySubmitted$
    .pipe(
      mergeMap((group$) =>
        group$.pipe(
          switchMap(({ tx }) => {
            const invalidHereafter = tx.body.validityInterval.invalidHereafter;
            return race(
              rollback$.pipe(
                map((rolledBackTx) => rolledBackTx.id),
                filter((rolledBackTxId) => tx.body.inputs.some(({ txId }) => txId === rolledBackTxId)),
                map(
                  (rolledBackTxId): FailedTx => ({
                    error: new Error(
                      `Invalid inputs due to rolled back tx (${rolledBackTxId}}). Try to rebuild and resubmit.`
                    ),
                    reason: TransactionFailure.InvalidTransaction,
                    tx
                  })
                )
              ),
              failedToSubmit$.pipe(filter((failed) => failed.tx === tx)),
              invalidHereafter
                ? tip$.pipe(
                    filter(({ slot }) => slot > invalidHereafter),
                    map(() => ({ reason: TransactionFailure.Timeout, tx }))
                  )
                : EMPTY
            ).pipe(take(1), takeUntil(txConfirmed$(tx)));
          })
        )
      ),
      tap((failed) => logger.debug(`Transaction ${failed.tx.id} failed`, failed.reason))
    )
    .subscribe(failed$);

  const txFailed$ = (tx: Cardano.NewTxAlonzo) =>
    failed$.pipe(
      filter((failed) => failed.tx === tx),
      take(1)
    );

  const txPending$ = (tx: Cardano.NewTxAlonzo) =>
    pending$.pipe(
      filter((pending) => pending === tx),
      withLatestFrom(tip$),
      map(([_, { slot }]) => ({ submittedAt: slot, tx }))
    );

  const inFlight$ = new TrackerSubject<TxInFlight[]>(
    submittingOrPreviouslySubmitted$.pipe(
      mergeMap((group$) =>
        group$.pipe(
          // Only keep 1 (latest) inner observable per tx id.
          switchMap(({ tx, submittedAt }) => {
            const done$ = race(txConfirmed$(tx), txFailed$(tx)).pipe(
              map(() => ({ op: 'remove' as const, tx })),
              share()
            );
            return merge(
              of({ op: 'add' as const, submittedAt, tx }),
              done$,
              submittedAt
                ? EMPTY
                : // NOTE: current implementation might incorrectly update 'submittedAt'
                  // if transaction was attempted to resubmit and appeared to be already submitted.
                  // This property currently does not necessarily correspond to
                  // time when transaction got into a mempool - it works more like 'lastAttemptToSubmitAt',
                  // which isn't necessarily bad as it might prevent frequent resubmissions in some cases
                  txPending$(tx).pipe(
                    map((pending) => ({ op: 'submitted' as const, submittedAt: pending.submittedAt, tx })),
                    takeUntil(done$)
                  )
            );
          })
        )
      ),
      scan((inFlight, props) => {
        const idx = inFlight.findIndex((txInFlight) => txInFlight.tx === props.tx);
        if (props.op === 'add') {
          const newInFlightTx = { submittedAt: props.submittedAt, tx: props.tx };
          if (idx >= 0) {
            return [...inFlight.slice(0, idx), newInFlightTx, ...inFlight.slice(idx + 1)];
          }
          return [...inFlight, newInFlightTx];
        }
        if (props.op === 'remove') {
          return [...inFlight.slice(0, idx), ...inFlight.slice(idx + 1)];
        }
        // props.op === 'submitted'
        return [
          ...inFlight.slice(0, idx),
          { submittedAt: props.submittedAt, tx: props.tx },
          ...inFlight.slice(idx + 1)
        ];
      }, [] as TxInFlight[]),
      tap((inFlight) => newTransactionsStore.set(inFlight)),
      tap((inFlight) => logger.debug(`${inFlight.length} in flight transactions`)),
      startWith([])
    )
  );

  const confirmed$ = new Subject<ConfirmedTx>();
  const confirmedSubscription = submittingOrPreviouslySubmitted$
    .pipe(mergeMap((group$) => group$.pipe(switchMap(({ tx }) => txConfirmed$(tx).pipe(takeUntil(txFailed$(tx)))))))
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
