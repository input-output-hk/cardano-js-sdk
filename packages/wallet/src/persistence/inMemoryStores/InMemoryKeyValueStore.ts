import { EMPTY, Observable, of } from 'rxjs';
import { InMemoryCollectionStore } from './InMemoryCollectionStore';
import { KeyValueCollection, KeyValueStore } from '../types';

export class InMemoryKeyValueStore<K, V>
  extends InMemoryCollectionStore<KeyValueCollection<K, V>>
  implements KeyValueStore<K, V>
{
  getValues(keys: K[]): Observable<V[]> {
    if (this.destroyed || keys.length === 0) return EMPTY;
    const result: V[] = [];
    for (const key of keys) {
      const value = this.docs.find((doc) => doc.key === key)?.value;
      if (!value) return EMPTY;
      result.push(value);
    }
    return of(result);
  }
  setValue(key: K, value: V): Observable<void> {
    if (this.destroyed) return EMPTY;
    const storedDocIndex = this.docs.findIndex((doc) => doc.key === key);
    if (storedDocIndex >= 0) {
      this.docs.splice(storedDocIndex, 1);
    }
    this.docs.push({ key, value });
    return of(void 0);
  }
}
