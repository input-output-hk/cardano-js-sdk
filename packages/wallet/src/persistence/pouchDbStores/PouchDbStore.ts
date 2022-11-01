import { EMPTY, Observable, from } from 'rxjs';
import { Logger } from 'ts-log';
import { toPouchDbDoc } from './util';
import PouchDB from 'pouchdb';

export abstract class PouchDbStore<T extends {}> {
  destroyed = false;
  protected idle: Promise<void> = Promise.resolve();
  protected readonly logger: Logger;
  protected readonly db: PouchDB.Database<T>;

  constructor(public dbName: string, logger: Logger) {
    this.logger = logger;
    this.db = new PouchDB<T>(dbName);
  }

  /**
   * Only used internally and for cleaning up after tests.
   * If you need to use this for other purposes, consider adding clear() or destroy() to stores interfaces.
   */
  async clearDB(): Promise<void> {
    const docs = await this.db.allDocs();
    await this.db.bulkDocs(
      docs.rows.map(
        (row) =>
          ({
            _deleted: true,
            _id: row.id,
            _rev: row.value.rev
          } as unknown as T)
      )
    );
  }

  /**
   * Might all destroy other stores, if the underlying PouchDb database is shared.
   */
  destroy(): Observable<void> {
    if (!this.destroyed) {
      this.destroyed = true;
      return from(this.db.destroy());
    }
    return EMPTY;
  }

  protected toPouchDbDoc(obj: T): T {
    return toPouchDbDoc(obj) as T;
  }

  async #getRev(docId: string) {
    const existingDoc = await this.db.get(docId).catch(() => void 0);
    return existingDoc?._rev;
  }

  protected forcePut(docId: string, doc: T) {
    if (this.destroyed) return EMPTY;
    const serializableDoc = this.toPouchDbDoc(doc);
    return from(
      (this.idle = this.idle
        .then(async () => {
          const pouchDbDoc = {
            _id: docId,
            _rev: await this.#getRev(docId),
            ...serializableDoc
          };
          // eslint-disable-next-line promise/always-return
          try {
            await this.db.put(pouchDbDoc, { force: true });
          } catch (error) {
            this.logger.error(`PouchDbStore(${this.dbName}): failed to forcePut`, pouchDbDoc, error);
          }
        })
        .catch(() => void 0))
    );
  }
}
