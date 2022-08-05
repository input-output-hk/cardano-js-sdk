/* eslint-disable promise/always-return */
import { DocumentStore } from '../types';
import { EMPTY, Observable } from 'rxjs';
import { PouchDbStore } from './PouchDbStore';
import { dummyLogger } from 'ts-log';
import { sanitizePouchDbDoc } from './util';

/**
 * PouchDB implementation that uses a shared db for multiple PouchDbDocumentStores
 */
export class PouchDbDocumentStore<T> extends PouchDbStore<T> implements DocumentStore<T> {
  readonly #docId: string;

  /**
   * @param dbName PouchDB database name
   * @param docId unique document id within the db
   * @param logger will silently swallow the errors if not set
   */
  constructor(dbName: string, docId: string, logger = dummyLogger) {
    super(dbName, logger);
    this.#docId = docId;
  }

  get(): Observable<T> {
    if (this.destroyed) return EMPTY;
    return new Observable((observer) => {
      this.db
        .get(this.#docId)
        .then((doc) => {
          observer.next(sanitizePouchDbDoc(doc));
          observer.complete();
        })
        .catch(observer.complete.bind(observer));
    });
  }

  set(doc: T): Observable<void> {
    return this.forcePut(this.#docId, doc);
  }
}
