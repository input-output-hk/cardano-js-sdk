/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Queries from './queries.js';
import { Asset, Cardano, ProviderUtil } from '@cardano-sdk/core';
import { bufferToHexString } from '@cardano-sdk/util';
import type { LastMintTxModel } from '../../../src/index.js';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';

export enum AssetWith {
  CIP25Metadata = 'CIP25Metadata'
}

export class AssetData {
  id: Cardano.AssetId;
  name: Cardano.AssetName;
  policyId: Cardano.PolicyId;
  metadata: any;
}

export class AssetFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async queryLastMintTx(policyId: Cardano.PolicyId, name: Cardano.AssetName) {
    this.#logger.debug('About to query last nft mint tx for asset', { name, policyId });
    const result: QueryResult<LastMintTxModel> = await this.#db.query(Queries.findLastNftMintTx, [
      Buffer.from(policyId, 'hex'),
      Buffer.from(name, 'hex')
    ]);
    return result.rows[0];
  }

  public async getAssets(desiredQty: number, options?: { with?: AssetWith[] }): Promise<AssetData[]> {
    this.#logger.debug(`About to fetch up to ${desiredQty} assets`);

    let query = Queries.withoutMetadata;
    if (options?.with?.includes(AssetWith.CIP25Metadata)) {
      query = Queries.withCIP25Metadata;
    }

    const result: QueryResult<{ policy: Buffer; name: Buffer; json: any }> = await this.#db.query(query, [desiredQty]);

    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No assets found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} assets desired, only ${resultsQty} results found`);
    }

    return result.rows.map(({ policy, name, json }) => {
      const hexPolicy = bufferToHexString(policy);
      const hexName = bufferToHexString(name);
      const policyId = hexPolicy as unknown as Cardano.PolicyId;
      const assetName = hexName as unknown as Cardano.AssetName;

      return {
        id: Cardano.AssetId(`${hexPolicy}${hexName}`),
        metadata: json
          ? Asset.NftMetadata.fromMetadatum(
              { name: assetName, policyId },
              new Map<bigint, Cardano.Metadatum>([[721n, ProviderUtil.jsonToMetadatum(json)]]),
              this.#logger
            )
          : null,
        name: assetName,
        policyId
      };
    });
  }
}
