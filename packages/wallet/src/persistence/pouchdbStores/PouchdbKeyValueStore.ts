/* eslint-disable promise/always-return */
/* eslint-disable brace-style */
import { KeyValueCollection, KeyValueStore } from '../types';
import { Observable, from } from 'rxjs';
import { PouchdbStore } from './PouchdbStore';
import { dummyLogger } from 'ts-log';
import { sanitizePouchdbDoc } from './util';

/**
 * PouchDB database that implements KeyValueStore by using keys as document _id
 */
export class PouchdbKeyValueStore<K extends string, V> extends PouchdbStore<V> implements KeyValueStore<K, V> {
  /**
   * @param {string} dbName collection name
   */
  constructor(dbName: string, logger = dummyLogger) {
    // Using a db per collection
    super(dbName, logger);
  }

  setAll(docs: KeyValueCollection<K, V>[]): Observable<void> {
    return from(
      (async (): Promise<void> => {
        try {
          await this.clearDB();
          await this.db.bulkDocs(
            docs.map(({ key, value }) => ({
              ...value,
              _id: key
            }))
          );
        } catch (error) {
          this.logger.error(`PouchdbDocumentStore(${this.dbName}): failed to setAll`, docs, error);
        }
      })()
    );
  }

  getValues(keys: K[]): Observable<V[]> {
    return new Observable((observer) => {
      this.db
        .bulkGet({ docs: keys.map((key) => ({ id: key })) })
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
    return from(
      this.db
        .put({
          _id: key,
          ...value
        })
        .catch((error) => {
          this.logger.error(`PouchdbDocumentStore(${this.dbName}): failed to set ${key}`, value, error);
        }) as Promise<void>
    );
  }
}
