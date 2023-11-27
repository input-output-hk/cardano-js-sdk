import { CollectionStore } from './types';
import { EMPTY, Subject, concat, defaultIfEmpty, race } from 'rxjs';

export const observeAll =
  <T>(store: CollectionStore<T>, updates$: Subject<T[]>) =>
  () => {
    if (store.destroyed) return EMPTY;
    return race(concat(store.getAll().pipe(defaultIfEmpty([])), updates$), updates$);
  };
