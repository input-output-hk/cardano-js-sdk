import { EMPTY, Subject, delay, of, tap } from 'rxjs';
import { InMemoryStore } from './InMemoryStore.js';
import { observeAll } from '../util.js';
import type { CollectionStore } from '../types.js';
import type { Observable } from 'rxjs';

export class InMemoryCollectionStore<T> extends InMemoryStore implements CollectionStore<T> {
  readonly #updates$ = new Subject<T[]>();
  protected docs: T[] = [];
  observeAll: CollectionStore<T>['observeAll'];

  constructor() {
    super();
    this.observeAll = observeAll(this, this.#updates$);
  }

  getAll(): Observable<T[]> {
    if (this.docs.length === 0 || this.destroyed) return EMPTY;
    return of(this.docs);
  }

  setAll(docs: T[]): Observable<void> {
    if (!this.destroyed) {
      this.docs = docs;
      return of(void 0).pipe(
        // if setAll is called on 1st emission of observeAll,
        // then this has to be asynchronous for observeAll to emit the 2nd item.
        // any delay duration is ok: it's enough that this is called in the next tick
        delay(1),
        tap(() => this.#updates$.next(this.docs))
      );
    }
    return EMPTY;
  }

  destroy(): Observable<void> {
    this.#updates$.complete();
    return super.destroy();
  }
}
