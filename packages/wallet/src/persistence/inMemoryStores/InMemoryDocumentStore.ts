import { EMPTY, of } from 'rxjs';
import { InMemoryStore } from './InMemoryStore.js';
import type { DocumentStore } from '../types.js';
import type { Observable } from 'rxjs';

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
}
