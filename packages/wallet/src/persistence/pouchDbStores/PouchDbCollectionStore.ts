import { CollectionStore } from '../types';
import { EMPTY, Observable, Subject, from } from 'rxjs';
import { Logger } from 'ts-log';
import { PouchDbStore } from './PouchDbStore';
import { observeAll } from '../util';
import { sanitizePouchDbDoc } from './util';

export type ComputePouchDbDocId<T> = (doc: T) => string;

export interface PouchDbCollectionStoreProps<T> {
  dbName: string;
  computeDocId?: ComputePouchDbDocId<T>;
}

/** PouchDB database that implements CollectionStore. Supports sorting by custom document _id */
export class PouchDbCollectionStore<T extends {}> extends PouchDbStore<T> implements CollectionStore<T> {
  readonly #computeDocId: ComputePouchDbDocId<T> | undefined;
  readonly #updates$ = new Subject<T[]>();

  observeAll: CollectionStore<T>['observeAll'];

  /**
   * @param props store properties
   * @param props.dbName PouchDB database name
   * @param props.computeDocId used for document sort order
   * @param logger will silently swallow the errors if not set
   */
  constructor({ dbName, computeDocId }: PouchDbCollectionStoreProps<T>, logger: Logger) {
    // Using a db per collection
    super(dbName, logger);
    this.observeAll = observeAll(this, this.#updates$);
    this.#computeDocId = computeDocId;
  }

  getAll(): Observable<T[]> {
    if (this.destroyed) return EMPTY;
    return new Observable((observer) => {
      this.fetchAllDocs({ include_docs: true })
        .then((result) => {
          const docs = result.map(({ doc }) => sanitizePouchDbDoc(doc!));
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
              ...this.toPouchDbDoc(doc),
              _id: this.#computeDocId?.(doc)
            }))
          );
          this.#updates$.next(docs);
        } catch (error) {
          this.logger.error(`PouchDbCollectionStore(${this.dbName}): failed to setAll`, docs, error);
        }
      }))
    );
  }

  destroy(): Observable<void> {
    this.#updates$.complete();
    return super.destroy();
  }
}
