import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { concat, defaultIfEmpty, of, switchMap, tap } from 'rxjs';
import type { CollectionStore, DocumentStore } from '../../persistence/index.js';
import type { Observable } from 'rxjs';

export class PersistentCollectionTrackerSubject<T> extends TrackerSubject<T[]> {
  readonly store: CollectionStore<T>;
  constructor(source: (localObjects: T[]) => Observable<T[]>, store: CollectionStore<T>) {
    const stored$ = store.getAll().pipe(defaultIfEmpty([]));
    super(
      stored$.pipe(
        switchMap((stored) => {
          const source$ = source(stored);
          return stored.length > 0 ? concat(of(stored), source$) : source$;
        })
      )
    );
    this.store = store;
  }
  next(value: T[]): void {
    this.store && this.store.setAll(value);
    super.next(value);
  }
}

export class PersistentDocumentTrackerSubject<T> extends TrackerSubject<T> {
  constructor(source$: Observable<T>, store: DocumentStore<T>) {
    super(concat(store.get(), source$.pipe(tap(store.set.bind(store)))));
  }
}
