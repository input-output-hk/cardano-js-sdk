import * as Queries from './queries';
import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetPolicyIdAndName, NftMetadataService } from './types';
import { Logger } from 'ts-log';
import { MetadataService } from '../Metadata';
import { Pool, QueryResult } from 'pg';

/**
 * Dependencies that are need to create DbSyncNftMetadataService
 */
export interface DbSyncNftMetadataServiceDependencies {
  metadataService: MetadataService;
  db: Pool;
  logger: Logger;
}

/**
 * NftMetadataService implementation using cardano-db-sync database as a source
 */
export class DbSyncNftMetadataService implements NftMetadataService {
  #db: Pool;
  #logger: Logger;
  #metadataService: MetadataService;

  constructor({ db, logger, metadataService }: DbSyncNftMetadataServiceDependencies) {
    this.#db = db;
    this.#logger = logger;
    this.#metadataService = metadataService;
  }

  async getNftMetadata(assetInfo: AssetPolicyIdAndName): Promise<Asset.NftMetadata | undefined> {
    // Perf: could query last mint tx metadata in 1 query instead of 2
    this.#logger.debug('Querying find last nft mint tx for asset:', assetInfo);
    const result: QueryResult<Queries.FindLastMintTxModel> = await this.#db.query(Queries.findLastNftMintTx, [
      Buffer.from(assetInfo.policyId, 'hex'),
      Buffer.from(assetInfo.name, 'hex')
    ]);
    if (result.rows.length === 0) return;
    const lastMintedTxId = Cardano.TransactionId(result.rows[0].tx_hash.toString('hex'));

    this.#logger.debug('Querying tx metadata', lastMintedTxId);
    const metadatas = await this.#metadataService.queryTxMetadataByHashes([lastMintedTxId]);
    const metadata = metadatas.get(lastMintedTxId);
    return Asset.util.metadatumToCip25(assetInfo, metadata, this.#logger);
  }
}
