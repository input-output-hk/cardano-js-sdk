/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable promise/always-return */
/* eslint-disable brace-style */
import { Cardano } from '@cardano-sdk/core';
import { EMPTY, Observable, from } from 'rxjs';
import { KeyValueCollection, KeyValueStore } from '../types';
import { PouchdbStore } from './PouchdbStore';
import { dummyLogger } from 'ts-log';
import { sanitizePouchdbDoc } from './util';

/**
 * PouchDB database that implements KeyValueStore by using keys as document _id
 */
export class PouchdbKeyValueStore<K extends string | Cardano.util.OpaqueString<any>, V>
  extends PouchdbStore<V>
  implements KeyValueStore<K, V>
{
  /**
   * @param dbName collection name
   * @param logger will silently swallow the errors if not set
   */
  constructor(dbName: string, logger = dummyLogger) {
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
              ...this.toPouchdbDoc(value),
              _id: key.toString()
            }))
          );
        } catch (error) {
          this.logger.error(`PouchdbDocumentStore(${this.dbName}): failed to setAll`, docs, error);
        }
      }))
    );
  }

  getValues(keys: K[]): Observable<V[]> {
    if (this.destroyed) return EMPTY;
    return new Observable((observer) => {
      this.db
        .bulkGet({ docs: keys.map((key) => ({ id: key.toString() })) })
        .then(({ results }) => {
          const values: V[] = [];
          for (const { docs } of results) {
            if (docs.length !== 1 || 'error' in docs[0]) {
              return observer.complete();
            }
            values.push(sanitizePouchdbDoc(docs[0].ok));
          }
          observer.next(values);
          observer.complete();
        })
        .catch(observer.complete.bind(observer));
    });
  }

  setValue(key: K, value: V): Observable<void> {
    return this.forcePut(key.toString(), value);
  }
}
