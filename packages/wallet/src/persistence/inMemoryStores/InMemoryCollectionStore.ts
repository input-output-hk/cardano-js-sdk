/* eslint-disable brace-style */
import { CollectionStore } from '../types';
import { EMPTY, Observable, Subject, of } from 'rxjs';
import { InMemoryStore } from './InMemoryStore';
import { observeAll } from '../util';

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
      this.#updates$.next(this.docs);
      return of(void 0);
    }
    return EMPTY;
  }

  destroy(): Observable<void> {
    this.#updates$.complete();
    return super.destroy();
  }
}
