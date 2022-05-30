import { CollectionStore } from '../types';
import { EMPTY, Observable, from } from 'rxjs';
import { PouchdbStore } from './PouchdbStore';
import { dummyLogger } from 'ts-log';
import { sanitizePouchdbDoc } from './util';

export type ComputePouchdbDocId<T> = (doc: T) => string;

/**
 * PouchDB database that implements CollectionStore.
 * Supports sorting by custom document _id
 */
export class PouchdbCollectionStore<T> extends PouchdbStore<T> implements CollectionStore<T> {
  readonly #computeDocId: ComputePouchdbDocId<T> | undefined;

  /**
   * @param dbName collection name
   * @param logger logger
   * @param computeDocId used for document sort order
   */
  constructor(dbName: string, logger = dummyLogger, computeDocId?: ComputePouchdbDocId<T>) {
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
          // eslint-disable-next-line promise/always-return
          if (docs.length > 0) observer.next(docs);
          observer.complete();
        })
        .catch(observer.complete.bind(observer));
    });
  }

  setAll(docs: T[]): Observable<void> {
    if (this.destroyed) return EMPTY;
    return from(
      (async (): Promise<void> => {
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
      })()
    );
  }
}
