import { Logger } from 'ts-log';
import PouchDB from 'pouchdb';

export abstract class PouchdbStore<T> {
  protected readonly logger: Logger;
  protected readonly db: PouchDB.Database<T>;

  constructor(protected dbName: string, logger: Logger) {
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
}
