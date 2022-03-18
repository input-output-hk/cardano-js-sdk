import { CollectionStore, DocumentStore } from '../../persistence';
import { Milliseconds } from '../types';
import {
  Observable,
  Subject,
  concat,
  defaultIfEmpty,
  delay,
  exhaustMap,
  merge,
  of,
  startWith,
  switchMap,
  takeUntil,
  tap,
  timeout
} from 'rxjs';
import { TrackerSubject } from './TrackerSubject';

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

export interface SyncableIntervalPersistentDocumentTrackerSubjectProps<T> {
  provider$: Observable<T>;
  trigger$: Observable<unknown>;
  store: DocumentStore<T>;
  pollInterval: Milliseconds;
  maxPollInterval: Milliseconds;
}

export interface SyncableIntervalPersistentDocumentTrackerSubjectInternals {
  externalTrigger$?: Subject<void>;
}

const triggerOrInterval$ = (trigger$: Observable<unknown>, interval: number): Observable<unknown> =>
  trigger$.pipe(timeout({ each: interval, with: () => concat(of(true), triggerOrInterval$(trigger$, interval)) }));

// Commemorating Java ☕
export class SyncableIntervalPersistentDocumentTrackerSubject<T> extends PersistentDocumentTrackerSubject<T> {
  #externalTrigger$ = new Subject<void>();

  constructor(
    {
      provider$,
      pollInterval,
      maxPollInterval,
      store,
      trigger$
    }: SyncableIntervalPersistentDocumentTrackerSubjectProps<T>,
    { externalTrigger$ = new Subject() }: SyncableIntervalPersistentDocumentTrackerSubjectInternals = {}
  ) {
    super(
      merge(
        // Trigger fetch:
        // - on start
        // - after some delay once fully synced
        triggerOrInterval$(trigger$, maxPollInterval).pipe(
          delay(pollInterval),
          startWith(null),
          // Throttle syncing by interval, cancel ongoing request on external trigger
          exhaustMap(() => merge(provider$).pipe(takeUntil(externalTrigger$)))
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
