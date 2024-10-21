import { Cardano } from '@cardano-sdk/core';
import { ConnectionStatus, PersistentDocumentTrackerSubject, tipEquals } from './util';
import { DocumentStore } from '../persistence';
import {
  EMPTY,
  Observable,
  Subject,
  auditTime,
  combineLatest,
  concat,
  distinctUntilChanged,
  exhaustMap,
  filter,
  finalize,
  merge,
  of,
  startWith,
  switchMap,
  takeUntil,
  tap,
  timeout
} from 'rxjs';
import { Logger } from 'ts-log';
import { Milliseconds } from './types';
import { SyncStatus } from '../types';
export interface TipTrackerProps {
  provider$: Observable<Cardano.Tip>;
  syncStatus: SyncStatus;
  connectionStatus$: Observable<ConnectionStatus>;
  store: DocumentStore<Cardano.Tip>;
  /** Once */
  minPollInterval: Milliseconds;
  maxPollInterval: Milliseconds;
  logger: Logger;
}

export interface TipTrackerInternals {
  externalTrigger$?: Subject<void>;
}

const triggerOrInterval$ = <T = unknown>(trigger$: Observable<T>, interval: number): Observable<T | boolean> =>
  trigger$.pipe(timeout({ each: interval, with: () => concat(of(true), triggerOrInterval$(trigger$, interval)) }));

export class TipTracker extends PersistentDocumentTrackerSubject<Cardano.Tip> {
  #externalTrigger$ = new Subject<void>();
  #logger: Logger;

  constructor(
    { provider$, minPollInterval, maxPollInterval, store, syncStatus, connectionStatus$, logger }: TipTrackerProps,
    { externalTrigger$ = new Subject() }: TipTrackerInternals = {}
  ) {
    super(
      merge(
        // schedule a fetch:
        // - after some delay once fully synced and online
        // - if it's not settled for maxPollInterval
        combineLatest([
          triggerOrInterval$(syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)), maxPollInterval).pipe(
            // Do not allow more than one fetch per minPollInterval.
            // The first syncStatus starts a minPollInterval timer. Only the latest emission from the minPollInterval
            // is emitted in case the syncStatus changes multiple times.
            auditTime(minPollInterval),
            // trigger fetch on start
            startWith(null)
          ),
          connectionStatus$
        ]).pipe(
          tap(([, connectionStatus]) => {
            logger.debug(connectionStatus === ConnectionStatus.down ? 'Skipping fetch tip' : 'Fetching tip...');
          }),
          // Throttle syncing by interval, cancel ongoing request on external trigger
          exhaustMap(([, connectionStatus]) =>
            connectionStatus === ConnectionStatus.down
              ? EMPTY
              : provider$.pipe(takeUntil(externalTrigger$.pipe(tap(() => logger.debug('Tip fetch canceled')))))
          ),
          distinctUntilChanged(tipEquals),
          tap((tip) => logger.debug('Fetched new tip', tip))
        ),
        // Always immediately restart request on external trigger
        externalTrigger$.pipe(
          switchMap(() => provider$),
          tap((tip) => logger.debug('External trigger fetched tip', tip))
        )
      ).pipe(finalize(() => this.#externalTrigger$.complete())),
      store
    );
    this.#externalTrigger$ = externalTrigger$;
    this.#logger = logger;
  }

  sync() {
    this.#logger.debug('Manual sync triggered');
    this.#externalTrigger$.next();
  }
}
