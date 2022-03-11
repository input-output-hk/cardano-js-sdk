/* eslint-disable brace-style */
import { CollectionStore } from '../types';
import { EMPTY, Observable, of } from 'rxjs';

export class InMemoryCollectionStore<T> implements CollectionStore<T> {
  protected docs: T[] = [];

  getAll(): Observable<T[]> {
    if (this.docs.length === 0) return EMPTY;
    return of(this.docs);
  }

  setAll(docs: T[]): Observable<void> {
    this.docs = docs;
    return of(void 0);
  }
}
