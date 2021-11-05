import { Milliseconds } from '../types';
import {
  Observable,
  Subject,
  distinctUntilChanged,
  exhaustMap,
  interval,
  merge,
  startWith,
  switchMap,
  takeUntil
} from 'rxjs';
import { TrackerSubject } from './TrackerSubject';
import { retryBackoff } from 'backoff-rxjs';

export type RetryOperator = () => ReturnType<typeof retryBackoff>;
export interface SourceTrackerConfig {
  pollInterval: Milliseconds;
  maxInterval: Milliseconds;
}

export interface SourceTrackerProps<T> {
  provider: () => Observable<T>;
  config: SourceTrackerConfig;
  equals: (t1: T, t2: T) => boolean;
}

export interface ProviderTrackerSubjectInternals {
  externalTrigger$?: Subject<void>;
  trigger$?: Observable<unknown>;
}

export class ProviderTrackerSubject<T> extends TrackerSubject<T> {
  #externalTrigger$ = new Subject<void>();

  constructor(
    { provider: provider$, config: { pollInterval, maxInterval }, equals }: SourceTrackerProps<T>,
    { externalTrigger$ = new Subject(), trigger$ = interval(pollInterval) }: ProviderTrackerSubjectInternals = {}
  ) {
    super(
      merge(
        // Fetch at regular interval
        trigger$.pipe(
          startWith(null),
          // Throttle syncing by interval, cancel ongoing request on external trigger
          exhaustMap(() => provider$().pipe(takeUntil(externalTrigger$)))
        ),
        // Always immediately restart request on external trigger
        externalTrigger$.pipe(switchMap(provider$))
      ).pipe(distinctUntilChanged(equals), retryBackoff({ initialInterval: pollInterval, maxInterval }))
    );
    this.#externalTrigger$ = externalTrigger$;
  }

  sync() {
    this.#externalTrigger$.next();
  }
}
