import { Cardano } from '@cardano-sdk/core';
import { ConnectionStatus, PersistentDocumentTrackerSubject, tipEquals } from './util';
import { DocumentStore } from '../persistence';
import {
  EMPTY,
  Observable,
  Subject,
  combineLatest,
  concat,
  delay,
  distinctUntilChanged,
  exhaustMap,
  filter,
  finalize,
  merge,
  of,
  startWith,
  switchMap,
  takeUntil,
  timeout
} from 'rxjs';
import { Milliseconds } from './types';
import { SyncStatus } from '../types';
export interface TipTrackerProps {
  provider$: Observable<Cardano.Tip>;
  syncStatus: SyncStatus;
  connectionStatus$: Observable<ConnectionStatus>;
  store: DocumentStore<Cardano.Tip>;
  /**
   * Once
   */
  minPollInterval: Milliseconds;
  maxPollInterval: Milliseconds;
}

export interface TipTrackerInternals {
  externalTrigger$?: Subject<void>;
}

const triggerOrInterval$ = <T = unknown>(trigger$: Observable<T>, interval: number): Observable<T | boolean> =>
  trigger$.pipe(timeout({ each: interval, with: () => concat(of(true), triggerOrInterval$(trigger$, interval)) }));

export class TipTracker extends PersistentDocumentTrackerSubject<Cardano.Tip> {
  #externalTrigger$ = new Subject<void>();

  constructor(
    { provider$, minPollInterval, maxPollInterval, store, syncStatus, connectionStatus$ }: TipTrackerProps,
    { externalTrigger$ = new Subject() }: TipTrackerInternals = {}
  ) {
    super(
      merge(
        // schedule a fetch:
        // - after some delay once fully synced and online
        // - if it's not settled for maxPollInterval
        combineLatest([
          triggerOrInterval$(syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)), maxPollInterval).pipe(
            // trigger fetch after some delay once fully synced and online
            delay(minPollInterval),
            // trigger fetch on start
            startWith(null)
          ),
          connectionStatus$
        ]).pipe(
          // Throttle syncing by interval, cancel ongoing request on external trigger
          exhaustMap(([_, connectionStatus]) =>
            connectionStatus === ConnectionStatus.down ? EMPTY : provider$.pipe(takeUntil(externalTrigger$))
          ),
          distinctUntilChanged(tipEquals)
        ),
        // Always immediately restart request on external trigger
        externalTrigger$.pipe(switchMap(() => provider$))
      ).pipe(finalize(() => this.#externalTrigger$.complete())),
      store
    );
    this.#externalTrigger$ = externalTrigger$;
  }

  sync() {
    this.#externalTrigger$.next();
  }
}
