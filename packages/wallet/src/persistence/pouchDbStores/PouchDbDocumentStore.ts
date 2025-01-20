import { DocumentStore } from '../types';
import { EMPTY, Observable, from } from 'rxjs';
import { Logger } from 'ts-log';
import { PouchDbStore } from './PouchDbStore';
import { sanitizePouchDbDoc } from './util';

/** PouchDB implementation that uses a shared db for multiple PouchDbDocumentStores */
export class PouchDbDocumentStore<T extends {}> extends PouchDbStore<T> implements DocumentStore<T> {
  readonly #docId: string;

  /**
   * @param dbName PouchDB database name
   * @param docId unique document id within the db
   * @param logger will silently swallow the errors if not set
   */
  constructor(dbName: string, docId: string, logger: Logger) {
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

  delete(): Observable<void> {
    if (this.destroyed) return EMPTY;
    return from(
      (async () => {
        const _rev = await this.getRev(this.#docId);
        if (!_rev) {
          // assuming already deleted
          return;
        }
        await this.db.remove({ _id: this.#docId, _rev });
      })()
    );
  }
}
