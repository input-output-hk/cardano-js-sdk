import { CollectionStore, DocumentStore } from '../../persistence';
import { Milliseconds } from '../types';
import {
  Observable,
  Subject,
  concat,
  defaultIfEmpty,
  exhaustMap,
  interval,
  merge,
  of,
  startWith,
  switchMap,
  takeUntil,
  tap
} from 'rxjs';
import { TrackerSubject } from './TrackerSubject';
import { retryBackoff } from 'backoff-rxjs';

export class PersistentCollectionTrackerSubject<T> extends TrackerSubject<T[]> {
  constructor(source: (localObjects: T[]) => Observable<T[]>, store: CollectionStore<T>) {
    const stored$ = store.getAll().pipe(defaultIfEmpty([]));
    super(
      stored$.pipe(
        switchMap((stored) => {
          const source$ = source(stored).pipe(tap(store.setAll.bind(store)));
          return stored.length > 0 ? concat(of(stored), source$) : source$;
        })
      )
    );
  }
}

export class PersistentDocumentTrackerSubject<T> extends TrackerSubject<T> {
  constructor(source$: Observable<T>, store: DocumentStore<T>) {
    super(concat(store.get(), source$.pipe(tap(store.set.bind(store)))));
  }
}

export type RetryOperator = () => ReturnType<typeof retryBackoff>;

export interface SyncableIntervalPersistentDocumentTrackerSubjectProps<T> {
  provider$: Observable<T>;
  store: DocumentStore<T>;
  pollInterval: Milliseconds;
}

export interface SyncableIntervalPersistentDocumentTrackerSubjectInternals {
  externalTrigger$?: Subject<void>;
  interval$?: Observable<unknown>;
}

// Commemorating Java ☕
export class SyncableIntervalPersistentDocumentTrackerSubject<T> extends PersistentDocumentTrackerSubject<T> {
  #externalTrigger$ = new Subject<void>();

  constructor(
    { provider$, pollInterval, store }: SyncableIntervalPersistentDocumentTrackerSubjectProps<T>,
    {
      externalTrigger$ = new Subject(),
      interval$ = interval(pollInterval)
    }: SyncableIntervalPersistentDocumentTrackerSubjectInternals = {}
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
      ),
      store
    );
    this.#externalTrigger$ = externalTrigger$;
  }

  sync() {
    this.#externalTrigger$.next();
  }
}
