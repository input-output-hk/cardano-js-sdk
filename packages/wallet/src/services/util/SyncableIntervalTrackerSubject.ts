import { Milliseconds } from '../types';
import { Observable, Subject, exhaustMap, interval, merge, startWith, switchMap, takeUntil } from 'rxjs';
import { TrackerSubject } from './TrackerSubject';
import { retryBackoff } from 'backoff-rxjs';

export type RetryOperator = () => ReturnType<typeof retryBackoff>;

export interface SourceTrackerProps<T> {
  provider$: Observable<T>;
  pollInterval: Milliseconds;
}

export interface ProviderTrackerSubjectInternals {
  externalTrigger$?: Subject<void>;
  interval$?: Observable<unknown>;
}

export class SyncableIntervalTrackerSubject<T> extends TrackerSubject<T> {
  #externalTrigger$ = new Subject<void>();

  constructor(
    { provider$, pollInterval }: SourceTrackerProps<T>,
    { externalTrigger$ = new Subject(), interval$ = interval(pollInterval) }: ProviderTrackerSubjectInternals = {}
  ) {
    super(
      merge(
        // Fetch at regular interval
        interval$.pipe(
          startWith(null),
          // Throttle syncing by interval, cancel ongoing request on external trigger
          exhaustMap(() => provider$.pipe(takeUntil(externalTrigger$)))
        ),
        // Always immediately restart request on external trigger
        externalTrigger$.pipe(switchMap(() => provider$))
      )
    );
    this.#externalTrigger$ = externalTrigger$;
  }

  sync() {
    this.#externalTrigger$.next();
  }
}
