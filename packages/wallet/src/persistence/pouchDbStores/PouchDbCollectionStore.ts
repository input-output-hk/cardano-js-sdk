import { CollectionStore } from '../types';
import { EMPTY, Observable, Subject, from } from 'rxjs';
import { Logger } from 'ts-log';
import { PouchDbStore } from './PouchDbStore';
import { observeAll } from '../util';
import { sanitizePouchDbDoc } from './util';
import { v4 } from 'uuid';

export type ComputePouchDbDocId<T> = (doc: T) => string;

export interface PouchDbCollectionStoreProps<T> {
  dbName: string;
  computeDocId?: ComputePouchDbDocId<T>;
}

/** PouchDB database that implements CollectionStore. Supports sorting by custom document _id */
export class PouchDbCollectionStore<T extends {}> extends PouchDbStore<T> implements CollectionStore<T> {
  readonly #computeDocId: ComputePouchDbDocId<T>;
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
    this.#computeDocId = computeDocId ?? (() => v4());
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
          const newDocsWithId = docs.map((doc) => ({
            ...this.toPouchDbDoc(doc),
            _id: this.#computeDocId(doc)
          }));
          const existingDocs = await this.fetchAllDocs();
          const newDocsWithRev = newDocsWithId.map((newDoc): T & { _id: string; _rev?: string } => {
            const existingDoc = existingDocs.find((doc) => doc.id === newDoc._id);
            if (!existingDoc) return newDoc;
            return {
              ...newDoc,
              _rev: existingDoc.value.rev
            };
          });
          const docsToDelete = existingDocs.filter(
            (existingDoc) => !newDocsWithId.some((newDoc) => newDoc._id === existingDoc.id)
          );
          await this.db.bulkDocs(
            docsToDelete.map(
              ({ id, value: { rev } }) =>
                ({
                  _deleted: true,
                  _id: id,
                  _rev: rev
                } as unknown as T)
            )
          );
          await this.db.bulkDocs(newDocsWithRev);

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
