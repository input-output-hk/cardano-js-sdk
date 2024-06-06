import * as Queries from './queries.js';
import type { Cardano } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';

export enum AddressWith {
  MultiAsset = 'multiAsset',
  AssetWithoutName = 'AssetWithoutName',
  ReferenceScript = 'ReferenceScript',
  InlineDatum = 'InlineDatum'
}

export class UtxoFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async getAddresses(
    desiredQty: number,
    options?: { with?: AddressWith[]; scriptType?: string }
  ): Promise<Cardano.PaymentAddress[]> {
    this.#logger.debug(`About to fetch up to ${desiredQty} addresses`);

    let result: QueryResult<{ address: string }>;

    if (options?.with?.includes(AddressWith.ReferenceScript)) {
      const type = options.scriptType ? options.scriptType : 'timelock';
      result = await this.#db.query(Queries.findAddressWithScriptRefUtxo, [desiredQty, type]);
    } else if (options?.with?.includes(AddressWith.InlineDatum)) {
      result = await this.#db.query(Queries.findAddressWithInlineDatumUtxo, [desiredQty]);
    } else {
      let query = Queries.findAddresses;

      if (options?.with?.includes(AddressWith.MultiAsset)) {
        query = Queries.beingMultiAssetAddresses;

        if (options?.with?.includes(AddressWith.AssetWithoutName)) {
          query += Queries.withMultiAssetWithoutName;
        }

        query += Queries.endMultiAssetAddresses;
      }
      result = await this.#db.query(query, [desiredQty]);
    }

    const resultsQty = result!.rows.length;
    if (result!.rows.length === 0) {
      throw new Error('No addresses found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} distinct addresses desired, only ${resultsQty} results found`);
    }

    return result!.rows.map(({ address }) => address as unknown as Cardano.PaymentAddress);
  }
}
