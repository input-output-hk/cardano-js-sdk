import * as Queries from './queries';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';

export enum AddressWith {
  MultiAsset = 'multiAsset',
  AssetWithoutName = 'AssetWithoutName'
}

export class UtxoFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async getAddresses(desiredQty: number, options?: { with?: AddressWith[] }): Promise<Cardano.Address[]> {
    this.#logger.debug(`About to fetch up to ${desiredQty} addresses`);

    let query = Queries.findAddresses;

    if (options?.with?.includes(AddressWith.MultiAsset)) {
      query = Queries.beingMultiAssetAddresses;

      if (options?.with?.includes(AddressWith.AssetWithoutName)) {
        query += Queries.withMultiAssetWithoutName;
      }

      query += Queries.endMultiAssetAddresses;
    }

    const result: QueryResult<{ address: string }> = await this.#db.query(query, [desiredQty]);
    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No addresses found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} distinct addresses desired, only ${resultsQty} results found`);
    }

    return result.rows.map(({ address }) => Cardano.Address(address));
  }
}
