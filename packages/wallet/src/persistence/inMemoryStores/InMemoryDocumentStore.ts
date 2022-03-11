/* eslint-disable brace-style */
import { DocumentStore } from '../types';
import { EMPTY, Observable, of } from 'rxjs';

export class InMemoryDocumentStore<T> implements DocumentStore<T> {
  private doc: T | null = null;
  get(): Observable<T> {
    if (!this.doc) return EMPTY;
    return of(this.doc);
  }
  set(doc: T): Observable<void> {
    this.doc = doc;
    return of(void 0);
  }
}
