/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable promise/always-return */
import { EMPTY, Observable, from } from 'rxjs';
import { PouchDbStore } from './PouchDbStore.js';
import { sanitizePouchDbDoc } from './util.js';
import type { KeyValueCollection, KeyValueStore } from '../types.js';
import type { Logger } from 'ts-log';
import type { OpaqueString } from '@cardano-sdk/util';

/** PouchDB database that implements KeyValueStore by using keys as document _id */
export class PouchDbKeyValueStore<K extends string | OpaqueString<any>, V extends {}>
  extends PouchDbStore<V>
  implements KeyValueStore<K, V>
{
  /**
   * @param dbName collection name
   * @param logger will silently swallow the errors if not set
   */
  constructor(dbName: string, logger: Logger) {
    // Using a db per collection
    super(dbName, logger);
  }

  setAll(docs: KeyValueCollection<K, V>[]): Observable<void> {
    if (this.destroyed) return EMPTY;
    return from(
      (this.idle = this.idle.then(async (): Promise<void> => {
        try {
          await this.clearDB();
          await this.db.bulkDocs(
            docs.map(({ key, value }) => ({
              ...this.toPouchDbDoc(value),
              _id: key
            }))
          );
        } catch (error) {
          this.logger.error(`PouchDbDocumentStore(${this.dbName}): failed to setAll`, docs, error);
        }
      }))
    );
  }

  getValues(keys: K[]): Observable<V[]> {
    if (this.destroyed) return EMPTY;
    return new Observable((observer) => {
      this.db
        .bulkGet({ docs: keys.map((key) => ({ id: key })) })
        .then(({ results }) => {
          const values: V[] = [];
          for (const { docs } of results) {
            if (docs.length !== 1 || 'error' in docs[0]) {
              return observer.complete();
            }
            values.push(sanitizePouchDbDoc(docs[0].ok));
          }
          observer.next(values);
          observer.complete();
        })
        .catch(observer.complete.bind(observer));
    });
  }

  setValue(key: K, value: V): Observable<void> {
    return this.forcePut(key, value);
  }
}
