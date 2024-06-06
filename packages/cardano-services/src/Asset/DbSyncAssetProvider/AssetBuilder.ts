import Queries from './queries.js';
import type { Cardano } from '@cardano-sdk/core';
import type { LastMintTxModel, MultiAssetModel } from './types.js';
import type { Logger } from 'ts-log';
import type { Pool } from 'pg';

export class AssetBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async queryLastMintTx(policyId: Cardano.PolicyId, name: Cardano.AssetName) {
    this.#logger.debug('About to query last nft mint tx for asset', { name, policyId });
    const result = await this.#db.query<LastMintTxModel>({
      name: 'nft_last_mint_tx',
      text: Queries.findLastNftMintTx,
      values: [Buffer.from(policyId, 'hex'), Buffer.from(name, 'hex')]
    });
    return result.rows[0];
  }

  public async queryMultiAsset(policyId: Cardano.PolicyId, name: Cardano.AssetName) {
    this.#logger.debug('About to query multi asset', { name, policyId });
    const result = await this.#db.query<MultiAssetModel>({
      name: 'find_multi_asset',
      text: Queries.findMultiAsset,
      values: [Buffer.from(policyId, 'hex'), Buffer.from(name, 'hex')]
    });
    return result.rows[0];
  }
}
