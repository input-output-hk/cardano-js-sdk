/* eslint-disable brace-style */
import { CollectionStore } from '../types';
import { EMPTY, Observable, of } from 'rxjs';
import { InMemoryStore } from './InMemoryStore';

export class InMemoryCollectionStore<T> extends InMemoryStore implements CollectionStore<T> {
  protected docs: T[] = [];

  getAll(): Observable<T[]> {
    if (this.docs.length === 0 || this.destroyed) return EMPTY;
    return of(this.docs);
  }

  setAll(docs: T[]): Observable<void> {
    if (!this.destroyed) {
      this.docs = docs;
      return of(void 0);
    }
    return EMPTY;
  }
}
