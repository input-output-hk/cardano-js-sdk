/* eslint-disable promise/always-return */
import { CollectionStore } from '../types';
import { EMPTY, Observable, from } from 'rxjs';
import { Logger, dummyLogger } from 'ts-log';
import { PouchdbStore } from './PouchdbStore';
import { sanitizePouchdbDoc } from './util';

export type ComputePouchdbDocId<T> = (doc: T) => string;

export interface PouchdbCollectionStoreProps<T> {
  dbName: string;
  computeDocId?: ComputePouchdbDocId<T>;
}

/**
 * PouchDB database that implements CollectionStore.
 * Supports sorting by custom document _id
 */
export class PouchdbCollectionStore<T> extends PouchdbStore<T> implements CollectionStore<T> {
  readonly #computeDocId: ComputePouchdbDocId<T> | undefined;

  /**
   * @param props store properties
   * @param props.dbName PouchDB database name
   * @param props.computeDocId used for document sort order
   * @param logger will silently swallow the errors if not set
   */
  constructor({ dbName, computeDocId }: PouchdbCollectionStoreProps<T>, logger: Logger = dummyLogger) {
    // Using a db per collection
    super(dbName, logger);
    this.#computeDocId = computeDocId;
  }

  getAll(): Observable<T[]> {
    if (this.destroyed) return EMPTY;
    return new Observable((observer) => {
      this.db
        .allDocs({ include_docs: true })
        .then((result) => {
          const docs = result.rows.map(({ doc }) => sanitizePouchdbDoc(doc!));
          if (docs.length > 0) observer.next(docs);
          observer.complete();
        })
        .catch(observer.complete.bind(observer));
    });
  }

  setAll(docs: T[]): Observable<void> {
    if (this.destroyed) return EMPTY;
    return from(
      (this.idle = this.idle.then(async (): Promise<void> => {
        try {
          await this.clearDB();
          await this.db.bulkDocs(
            docs.map((doc) => ({
              ...this.toPouchdbDoc(doc),
              _id: this.#computeDocId?.(doc)
            }))
          );
        } catch (error) {
          this.logger.error(`PouchdbCollectionStore(${this.dbName}): failed to setAll`, docs, error);
        }
      }))
    );
  }
}
