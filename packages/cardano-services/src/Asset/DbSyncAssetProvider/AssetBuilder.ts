import { Cardano } from '@cardano-sdk/core';
import { LastMintTxModel, MultiAssetHistoryModel, MultiAssetModel, MultiAssetQuantitiesModel } from './types';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import Queries from './queries';

export class AssetBuilder {
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

  public async queryMultiAsset(policyId: Cardano.PolicyId, name: Cardano.AssetName) {
    this.#logger.debug('About to query multi asset', { name, policyId });
    const result: QueryResult<MultiAssetModel> = await this.#db.query(Queries.findMultiAsset, [
      Buffer.from(policyId, 'hex'),
      Buffer.from(name, 'hex')
    ]);
    return result.rows[0];
  }

  public async queryMultiAssetHistory(policyId: Cardano.PolicyId, name: Cardano.AssetName) {
    this.#logger.debug('About to query multi asset history', { name, policyId });
    const result: QueryResult<MultiAssetHistoryModel> = await this.#db.query(Queries.findMultiAssetHistory, [
      Buffer.from(policyId, 'hex'),
      Buffer.from(name, 'hex')
    ]);
    return result.rows;
  }

  public async queryMultiAssetQuantities(id: string) {
    this.#logger.debug('About to query multi asset quantities', { id });
    const result: QueryResult<MultiAssetQuantitiesModel> = await this.#db.query(Queries.findMultiAssetQuantities, [id]);
    return result.rows[0];
  }
}
