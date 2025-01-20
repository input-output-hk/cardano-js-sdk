import { DocumentStore } from '../types';
import { EMPTY, Observable, of } from 'rxjs';
import { InMemoryStore } from './InMemoryStore';

export class InMemoryDocumentStore<T> extends InMemoryStore implements DocumentStore<T> {
  #doc: T | null = null;

  get(): Observable<T> {
    if (!this.#doc || this.destroyed) return EMPTY;
    return of(this.#doc);
  }

  set(doc: T): Observable<void> {
    if (!this.destroyed) {
      this.#doc = doc;
      return of(void 0);
    }
    return EMPTY;
  }

  delete(): Observable<void> {
    if (this.destroyed) return EMPTY;
    this.#doc = null;
    return of(void 0);
  }
}
