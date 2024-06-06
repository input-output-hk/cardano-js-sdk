import { EMPTY, concat, defaultIfEmpty, race } from 'rxjs';
import type { CollectionStore } from './types.js';
import type { Subject } from 'rxjs';

export const observeAll =
  <T>(store: CollectionStore<T>, updates$: Subject<T[]>) =>
  () => {
    if (store.destroyed) return EMPTY;
    return race(concat(store.getAll().pipe(defaultIfEmpty([])), updates$), updates$);
  };
