import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { DocumentStore, OrderedCollectionStore } from '../persistence';
import {
  EMPTY,
  NEVER,
  Observable,
  Subject,
  combineLatest,
  concat,
  defaultIfEmpty,
  distinctUntilChanged,
  exhaustMap,
  filter,
  from,
  map,
  merge,
  mergeMap,
  mergeWith,
  of,
  partition,
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
import { FailedTx, OutgoingOnChainTx, OutgoingTx, TransactionFailure, TransactionsTracker, TxInFlight } from './types';
import { Logger } from 'ts-log';
import { Range, Shutdown, contextLogger } from '@cardano-sdk/util';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackerSubject, coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { distinctBlock, signedTxsEquals, transactionsEquals, txInEquals } from './util';

import { WitnessedTx } from '@cardano-sdk/key-management';
import { newAndStoredMulticast } from './util/newAndStoredMulticast';
import chunk from 'lodash/chunk.js';
import intersectionBy from 'lodash/intersectionBy.js';
import sortBy from 'lodash/sortBy.js';
import unionBy from 'lodash/unionBy.js';

export interface TransactionsTrackerProps {
  chainHistoryProvider: ChainHistoryProvider;
  addresses$: Observable<Cardano.PaymentAddress[]>;
  tip$: Observable<Cardano.Tip>;
  retryBackoffConfig: RetryBackoffConfig;
  transactionsHistoryStore: OrderedCollectionStore<Cardano.HydratedTx>;
  inFlightTransactionsStore: DocumentStore<TxInFlight[]>;
  signedTransactionsStore: DocumentStore<WitnessedTx[]>;
  newTransactions: {
    submitting$: Observable<OutgoingTx>;
    pending$: Observable<OutgoingTx>;
    failedToSubmit$: Observable<FailedTx>;
    signed$: Observable<WitnessedTx>;
  };
  failedFromReemitter$?: Observable<FailedTx>;
  logger: Logger;
  onFatalError?: (value: unknown) => void;
}

export interface TransactionsTrackerInternals {
  transactionsSource$: Observable<Cardano.HydratedTx[]>;
  rollback$: Observable<Cardano.HydratedTx>;
}

export interface TransactionsTrackerInternalsProps {
  chainHistoryProvider: ChainHistoryProvider;
  addresses$: Observable<Cardano.PaymentAddress[]>;
  retryBackoffConfig: RetryBackoffConfig;
  tipBlockHeight$: Observable<Cardano.BlockNo>;
  store: OrderedCollectionStore<Cardano.HydratedTx>;
  logger: Logger;
  onFatalError?: (value: unknown) => void;
}

// Temporarily hardcoded. Will be replaced with ChainHistoryProvider 'maxPageSize' value once ADP-2249 is implemented
export const PAGE_SIZE = 25;

const allTransactionsByAddresses = async (
  chainHistoryProvider: ChainHistoryProvider,
  { addresses, blockRange }: { addresses: Cardano.PaymentAddress[]; blockRange: Range<Cardano.BlockNo> }
): Promise<Cardano.HydratedTx[]> => {
  const addressesSubGroups = chunk(addresses, PAGE_SIZE);
  let response: Cardano.HydratedTx[] = [];

  for (const addressGroup of addressesSubGroups) {
    let startAt = 0;
    let pageResults: Cardano.HydratedTx[] = [];

    do {
      pageResults = (
        await chainHistoryProvider.transactionsByAddresses({
          addresses: addressGroup,
          blockRange,
          pagination: { limit: PAGE_SIZE, startAt }
        })
      ).pageResults;

      startAt += PAGE_SIZE;
      response = [...response, ...pageResults];
    } while (pageResults.length === PAGE_SIZE);
  }

  return response;
};

export const createAddressTransactionsProvider = ({
  chainHistoryProvider,
  addresses$,
  retryBackoffConfig,
  tipBlockHeight$,
  store,
  logger,
  onFatalError
}: TransactionsTrackerInternalsProps): TransactionsTrackerInternals => {
  const rollback$ = new Subject<Cardano.HydratedTx>();
  const storedTransactions$ = store.getAll().pipe(share());
  return {
    rollback$: rollback$.asObservable(),
    transactionsSource$: concat(
      storedTransactions$.pipe(
        tap((storedTransactions) =>
          logger.debug(`Stored history transactions count: ${storedTransactions?.length || 0}`)
        )
      ),
      combineLatest([addresses$, storedTransactions$.pipe(defaultIfEmpty([] as Cardano.HydratedTx[]))]).pipe(
        switchMap(([addresses, storedTransactions]) => {
          let localTransactions: Cardano.HydratedTx[] = [...storedTransactions];

          return coldObservableProvider({
            // Do not re-fetch transactions twice on load when tipBlockHeight$ loads from storage first
            // It should also help when using poor internet connection.
            // Caveat is that local transactions might get out of date...
            combinator: exhaustMap,
            equals: transactionsEquals,
            onFatalError,
            provider: async () => {
              // eslint-disable-next-line no-constant-condition
              while (true) {
                const lastStoredTransaction: Cardano.HydratedTx | undefined =
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
  transactions$: Observable<Cardano.HydratedTx[]>
): TrackerSubject<Cardano.HydratedTx[]> =>
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

export const newTransactions$ = <T extends Pick<Cardano.Tx, 'id'>>(transactions$: Observable<T[]>) =>
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
    newTransactions: { submitting$: newSubmitting$, pending$, signed$: newSigned$, failedToSubmit$ },
    retryBackoffConfig,
    transactionsHistoryStore: transactionsStore,
    inFlightTransactionsStore: newTransactionsStore,
    signedTransactionsStore,
    logger,
    failedFromReemitter$,
    onFatalError
  }: TransactionsTrackerProps,
  { transactionsSource$: txSource$, rollback$ }: TransactionsTrackerInternals = createAddressTransactionsProvider({
    addresses$,
    chainHistoryProvider,
    logger: contextLogger(logger, 'AddressTransactionsProvider'),
    onFatalError,
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

  const [onChainNewTxPhase2Failed$, onChainNewTxSuccess$] = partition(
    newTransactions$(historicalTransactions$).pipe(share()),
    (tx) => Cardano.util.isPhase2ValidationErrTx(tx)
  );

  const txOnChain$ = (evt: OutgoingTx): Observable<OutgoingOnChainTx> =>
    merge(
      historicalTransactions$.pipe(
        take(1),
        mergeMap((txs) => from(txs))
      ),
      onChainNewTxSuccess$
    ).pipe(
      filter((historyTx) => historyTx.id === evt.id),
      take(1),
      map((historyTx) => ({ ...evt, slot: historyTx.blockHeader.slot })),
      tap(({ slot }) => logger.debug(`Transaction ${evt.id} is on-chain in slot ${slot}`))
    );

  const submittingOrPreviouslySubmitted$ = newAndStoredMulticast<TxInFlight, Cardano.TransactionId>({
    groupByFn: ({ id }) => id,
    logStringfn: (transactions) => `Store contains ${transactions?.length} in flight transactions`,
    logger,
    new$: submitting$,
    stored$: newTransactionsStore.get(),
    storedFilterfn: ({ submittedAt }) => !!submittedAt
  });

  const newSignedOrPreviouslySigned$ = newAndStoredMulticast<WitnessedTx, Cardano.TransactionId>({
    groupByFn: ({ tx }) => tx.id,
    logStringfn: (WitnessedTxs) => `Store contains ${WitnessedTxs?.length} signed transactions`,
    logger,
    new$: newSigned$,
    stored$: signedTransactionsStore.get()
  });

  const failed$ = new Subject<FailedTx>();
  const failedSubscription = submittingOrPreviouslySubmitted$
    .pipe(
      mergeMap((group$) =>
        group$.pipe(
          switchMap((tx) => {
            const invalidHereafter = tx.body.validityInterval?.invalidHereafter;
            return race(
              onChainNewTxPhase2Failed$.pipe(
                filter((failedTx) => failedTx.id === tx.id),
                map((): FailedTx => ({ reason: TransactionFailure.Phase2Validation, ...tx }))
              ),
              rollback$.pipe(
                map((rolledBackTx) => rolledBackTx.id),
                filter((rolledBackTxId) => tx.body.inputs.some(({ txId }) => txId === rolledBackTxId)),
                map(
                  (rolledBackTxId): FailedTx => ({
                    error: new Error(
                      `Invalid inputs due to rolled back tx (${rolledBackTxId}}). Try to rebuild and resubmit.`
                    ),
                    reason: TransactionFailure.InvalidTransaction,
                    ...tx
                  })
                )
              ),
              failedToSubmit$.pipe(filter((failed) => failed.id === tx.id)),
              invalidHereafter
                ? tip$.pipe(
                    filter(({ slot }) => slot > invalidHereafter),
                    map(() => ({ reason: TransactionFailure.Timeout, ...tx }))
                  )
                : NEVER
            ).pipe(take(1), takeUntil(txOnChain$(tx)));
          })
        )
      ),
      mergeWith(failedFromReemitter$ || EMPTY),
      tap(({ id, reason }) => logger.debug(`Transaction ${id} failed`, reason))
    )
    .subscribe(failed$);

  const txFailed$ = (tx: OutgoingTx) =>
    failed$.pipe(
      filter((failed) => failed.id === tx.id),
      take(1)
    );

  const txPending$ = (tx: OutgoingTx) =>
    pending$.pipe(
      filter((pending) => pending.id === tx.id),
      withLatestFrom(tip$),
      map(([_, { slot }]) => ({ submittedAt: slot, ...tx }))
    );

  const inFlight$ = new TrackerSubject<TxInFlight[]>(
    submittingOrPreviouslySubmitted$.pipe(
      mergeMap((group$) =>
        group$.pipe(
          // Only keep 1 (latest) inner observable per tx id.
          switchMap((tx) => {
            const done$ = race(txOnChain$(tx), txFailed$(tx)).pipe(
              map(() => ({ op: 'remove' as const, tx })),
              share()
            );
            return merge(
              of({ op: 'add' as const, tx }),
              done$,
              tx.submittedAt
                ? EMPTY
                : // NOTE: current implementation might incorrectly update 'submittedAt'
                  // if transaction was attempted to resubmit and appeared to be already submitted.
                  // This property currently does not necessarily correspond to
                  // time when transaction got into a mempool - it works more like 'lastAttemptToSubmitAt',
                  // which isn't necessarily bad as it might prevent frequent resubmissions in some cases
                  txPending$(tx).pipe(
                    map((pendingTx) => ({
                      op: 'submitted' as const,
                      tx: pendingTx
                    })),
                    takeUntil(done$)
                  )
            );
          })
        )
      ),
      scan((inFlight, props) => {
        const idx = inFlight.findIndex((txInFlight) => txInFlight.id === props.tx.id);
        if (props.op === 'add') {
          if (idx >= 0) {
            return [...inFlight.slice(0, idx), props.tx, ...inFlight.slice(idx + 1)];
          }
          return [...inFlight, props.tx];
        }
        if (props.op === 'remove') {
          return [...inFlight.slice(0, idx), ...inFlight.slice(idx + 1)];
        }
        // props.op === 'submitted'
        return [...inFlight.slice(0, idx), props.tx, ...inFlight.slice(idx + 1)];
      }, [] as TxInFlight[]),
      tap((inFlight) => newTransactionsStore.set(inFlight)),
      tap((inFlight) => logger.debug(`${inFlight.length} in flight transactions`)),
      startWith([])
    )
  );

  const signed$ = new TrackerSubject<WitnessedTx[]>(
    merge(
      newSignedOrPreviouslySigned$.pipe(
        mergeMap((WitnessedTx$) => WitnessedTx$),
        map((witnessedTx) => ({ op: 'add' as const, witnessedTx }))
      ),
      inFlight$.pipe(
        mergeMap((txs) => txs),
        map((tx) => ({ id: tx.id, op: 'remove' as const }))
      ),
      historicalTransactions$.pipe(
        map((txs) => ({
          inputs: txs.flatMap((tx) => tx.body.inputs.map((inputs) => inputs)),
          op: 'check_inputs' as const
        }))
      ),
      tip$.pipe(map(({ slot }) => ({ op: 'check_interval' as const, slot })))
    ).pipe(
      scan((signed, action) => {
        if (action.op === 'add') {
          return [...signed, action.witnessedTx];
        }
        if (action.op === 'remove') {
          return signed.filter(({ tx }) => tx.id !== action.id);
        }
        if (action.op === 'check_interval') {
          return signed.filter(
            ({
              tx: {
                body: { validityInterval: { invalidHereafter } = {} }
              }
            }) => invalidHereafter && invalidHereafter > action.slot
          );
        }
        if (action.op === 'check_inputs') {
          return signed.filter(({ tx }) => {
            const anyUtxoIsUsed = tx.body.inputs.some((WitnessedTxInput) =>
              action.inputs.some((historicalInput) => txInEquals(WitnessedTxInput, historicalInput))
            );

            return !anyUtxoIsUsed;
          });
        }
        return signed;
      }, [] as WitnessedTx[]),
      tap((signed) => signedTransactionsStore.set(signed)),
      startWith([]),
      distinctUntilChanged(signedTxsEquals)
    )
  );

  const onChain$ = new Subject<OutgoingOnChainTx>();
  const onChainSubscription = submittingOrPreviouslySubmitted$
    .pipe(mergeMap((group$) => group$.pipe(switchMap((tx) => txOnChain$(tx).pipe(takeUntil(txFailed$(tx)))))))
    .subscribe(onChain$);

  return {
    history$: historicalTransactions$,
    outgoing: {
      failed$,
      inFlight$,
      onChain$,
      pending$,
      signed$,
      submitting$
    },
    rollback$,
    shutdown: () => {
      inFlight$.complete();
      onChainSubscription.unsubscribe();
      onChain$.complete();
      failedSubscription.unsubscribe();
      failed$.complete();
      logger.debug('Shutdown');
    }
  };
};
