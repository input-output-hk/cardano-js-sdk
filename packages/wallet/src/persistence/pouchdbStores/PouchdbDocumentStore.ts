/* eslint-disable promise/always-return */
import { DocumentStore } from '../types';
import { Observable, from } from 'rxjs';
import { PouchdbStore } from './PouchdbStore';
import { dummyLogger } from 'ts-log';
import { sanitizePouchdbDoc } from './util';

/**
 * PouchDB implementation that uses a shared db for multiple PouchDbDocumentStores
 */
export class PouchdbDocumentStore<T> extends PouchdbStore<T> implements DocumentStore<T> {
  readonly #docId: string;

  constructor(dbName: string, docId: string, logger = dummyLogger) {
    super(dbName, logger);
    this.#docId = docId;
  }

  get(): Observable<T> {
    return new Observable((observer) => {
      this.db
        .get(this.#docId)
        .then((doc) => {
          observer.next(sanitizePouchdbDoc(doc));
          observer.complete();
        })
        .catch(observer.complete.bind(observer));
    });
  }

  set(doc: T): Observable<void> {
    return from(
      this.db
        .put(
          {
            _id: this.#docId,
            ...this.toPouchdbDoc(doc)
          },
          { force: true }
        )
        .catch((error) =>
          this.logger.error(`PouchdbDocumentStore(${this.#docId}): failed to set`, doc, error)
        ) as Promise<void>
    );
  }
}
