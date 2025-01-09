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
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { distinctBlock, pollProvider, signedTxsEquals, transactionsEquals, txEquals, txInEquals } from './util';

import { WitnessedTx } from '@cardano-sdk/key-management';
import { newAndStoredMulticast } from './util/newAndStoredMulticast';
import chunk from 'lodash/chunk.js';
import sortBy from 'lodash/sortBy.js';

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
}

// Temporarily hardcoded. Will be replaced with ChainHistoryProvider 'maxPageSize' value once ADP-2249 is implemented
export const PAGE_SIZE = 25;

/**
 * Sorts the given HydratedTx by slot.
 *
 * @param lhs The left-hand side of the comparison operation.
 * @param rhs The left-hand side of the comparison operation.
 */
const sortTxBySlot = (lhs: Cardano.HydratedTx, rhs: Cardano.HydratedTx) => lhs.blockHeader.slot - rhs.blockHeader.slot;

/**
 * Deduplicates the given array of HydratedTx.
 *
 * @param arr The array of HydratedTx to deduplicate.
 * @param isEqual The equality function to use to determine if two HydratedTx are equal.
 */
const deduplicateSortedArray = (
  arr: Cardano.HydratedTx[],
  isEqual: (a: Cardano.HydratedTx, b: Cardano.HydratedTx) => boolean
) => {
  if (arr.length === 0) {
    return [];
  }

  const result = [arr[0]];

  for (let i = 1; i < arr.length; ++i) {
    if (!isEqual(arr[i], arr[i - 1])) {
      result.push(arr[i]);
    }
  }

  return result;
};

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

  return deduplicateSortedArray(response.sort(sortTxBySlot), txEquals);
};

const getLastTransactionsAtBlock = (
  transactions: Cardano.HydratedTx[],
  blockNo: Cardano.BlockNo
): Cardano.HydratedTx[] => {
  const txsFromSameBlock = [];

  for (let i = transactions.length - 1; i >= 0; --i) {
    const tx = transactions[i];
    if (tx.blockHeader.blockNo === blockNo) {
      txsFromSameBlock.push(tx);
    } else {
      break;
    }
  }

  // Since we are traversing the array in reverse to find the transactions for this block,
  // we must reverse the result.
  return txsFromSameBlock.reverse();
};

export const revertLastBlock = (
  localTransactions: Cardano.HydratedTx[],
  blockNo: Cardano.BlockNo,
  rollback$: Subject<Cardano.HydratedTx>,
  newTransactions: Cardano.HydratedTx[],
  logger: Logger
) => {
  const result = [...localTransactions];

  while (result.length > 0) {
    const lastKnownTx = result[result.length - 1];

    if (lastKnownTx.blockHeader.blockNo === blockNo) {
      // only emit if the tx is also not present in the new transactions to be added
      if (newTransactions.findIndex((tx) => tx.id === lastKnownTx.id) === -1) {
        logger.debug(`Transaction ${lastKnownTx.id} was rolled back`);
        rollback$.next(lastKnownTx);
      }

      result.pop();
    } else {
      break;
    }
  }

  return deduplicateSortedArray(result, txEquals);
};

const findIntersectionAndUpdateTxStore = ({
  chainHistoryProvider,
  logger,
  store,
  retryBackoffConfig,
  tipBlockHeight$,
  rollback$,
  localTransactions,
  addresses
}: Pick<
  TransactionsTrackerInternalsProps,
  'chainHistoryProvider' | 'logger' | 'store' | 'retryBackoffConfig' | 'tipBlockHeight$'
> & {
  localTransactions: Cardano.HydratedTx[];
  rollback$: Subject<Cardano.HydratedTx>;
  addresses: Cardano.PaymentAddress[];
}) =>
  pollProvider({
    // Do not re-fetch transactions twice on load when tipBlockHeight$ loads from storage first
    // It should also help when using poor internet connection.
    // Caveat is that local transactions might get out of date...
    combinator: exhaustMap,
    equals: transactionsEquals,
    logger,
    retryBackoffConfig,
    // eslint-disable-next-line sonarjs/cognitive-complexity,complexity
    sample: async () => {
      let rollbackOcurred = false;
      // eslint-disable-next-line no-constant-condition
      while (true) {
        const lastStoredTransaction: Cardano.HydratedTx | undefined = localTransactions[localTransactions.length - 1];

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

        // Fetching transactions from scratch, nothing else to do here.
        if (lowerBound === undefined) {
          if (newTransactions.length > 0) {
            localTransactions = newTransactions;
            store.setAll(newTransactions);
          }

          return newTransactions;
        }

        // If no transactions found from that block range, it means the last known block has been rolled back.
        if (newTransactions.length === 0) {
          localTransactions = revertLastBlock(localTransactions, lowerBound, rollback$, newTransactions, logger);
          rollbackOcurred = true;

          continue;
        }

        const localTxsFromSameBlock = getLastTransactionsAtBlock(localTransactions, lowerBound);
        const firstSegmentOfNewTransactions = newTransactions.slice(0, localTxsFromSameBlock.length);
        const hasSameLength = localTxsFromSameBlock.length === firstSegmentOfNewTransactions.length;

        // The first segment of new transaction should match exactly (same txs and same order) our last know TXs. Otherwise
        // roll them back and re-apply in new order.
        const sameTxAndOrder =
          hasSameLength &&
          localTxsFromSameBlock.every((tx, index) => tx.id === firstSegmentOfNewTransactions[index].id);

        if (!sameTxAndOrder) {
          localTransactions = revertLastBlock(localTransactions, lowerBound, rollback$, newTransactions, logger);
          rollbackOcurred = true;

          continue;
        }

        // No rollbacks, if they overlap 100% do nothing, otherwise add the difference.
        const areTransactionsSame =
          newTransactions.length === localTxsFromSameBlock.length &&
          localTxsFromSameBlock.every((tx, index) => tx.id === newTransactions[index].id);

        if (!areTransactionsSame) {
          // Skip overlapping transactions to avoid duplicates
          localTransactions = deduplicateSortedArray(
            [...localTransactions, ...newTransactions.slice(localTxsFromSameBlock.length)],
            txEquals
          );
          store.setAll(localTransactions);
        } else if (rollbackOcurred) {
          // This case handles rollbacks without new additions
          store.setAll(localTransactions);
        }

        return localTransactions;
      }
    },
    trigger$: tipBlockHeight$
  });

export const createAddressTransactionsProvider = (
  props: TransactionsTrackerInternalsProps
): TransactionsTrackerInternals => {
  const { addresses$, store, logger } = props;
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
        switchMap(([addresses, storedTransactions]) =>
          findIntersectionAndUpdateTxStore({
            addresses,
            localTransactions: deduplicateSortedArray([...storedTransactions].sort(sortTxBySlot), txEquals),
            rollback$,
            ...props
          })
        )
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
    failedFromReemitter$
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

  const historicalTransactions$ = createHistoricalTransactionsTrackerSubject(transactionsSource$).pipe(
    tap((transactions) => logger.debug(`History transactions count: ${transactions?.length || 0}`))
  );

  const new$ = newTransactions$(historicalTransactions$).pipe(share());

  const [onChainNewTxPhase2Failed$, onChainNewTxSuccess$] = partition(new$, (tx) =>
    Cardano.util.isPhase2ValidationErrTx(tx)
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
    new$,
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
