import { contextLogger } from '@cardano-sdk/util';
import { findCurrentEpoch, findFirstUpdateAfterBlock, findLastRetire, findPools } from './queries.js';
import { mapFirstUpdateAfterBlock } from './mappers.js';
import type {
  CurrentEpochModel,
  FirstUpdateAfterBlock,
  FirstUpdateAfterBlockModel,
  LastRetireModel,
  PoolsModel
} from './types.js';
import type { Logger } from 'ts-log';
import type { Pool } from 'pg';

export class BlockfrostCacheBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = contextLogger(logger, 'builder');
  }

  async getCurrentEpoch() {
    this.#logger.debug('Going to query current epoch');
    const result = await this.#db.query<CurrentEpochModel>(findCurrentEpoch);

    return result.rows[0].epoch_no;
  }

  async getFirstUpdateAfterBlock(id: string, blockNo: number): Promise<FirstUpdateAfterBlock | undefined> {
    this.#logger.debug(`Going to query first update for pool ${id} after block ${blockNo}`);
    const result = await this.#db.query<FirstUpdateAfterBlockModel>(findFirstUpdateAfterBlock, [id, blockNo]);

    return result.rows.map(mapFirstUpdateAfterBlock)[0];
  }

  async getLastRetire(id: string): Promise<LastRetireModel | undefined> {
    this.#logger.debug(`Going to query last retire for pool ${id}`);
    const result = await this.#db.query<LastRetireModel>(findLastRetire, [id]);

    return result.rows[0];
  }

  async getPools(cacheTtl: number) {
    const since = Date.now() - cacheTtl * 60_000;
    this.#logger.debug('Going to query stake pools to be refreshed');
    const result = await this.#db.query<PoolsModel>(findPools, [since]);
    this.#logger.debug('Stake pools to refresh', result.rowCount);

    return result.rows;
  }
}
