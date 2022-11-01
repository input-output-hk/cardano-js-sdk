import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetBuilder } from './AssetBuilder';
import { AssetPolicyIdAndName, NftMetadataService } from './types';
import { Logger } from 'ts-log';
import { Pool } from 'pg';
import { TxMetadataService } from '../Metadata';

/**
 * Dependencies that are need to create DbSyncNftMetadataService
 */
export interface DbSyncNftMetadataServiceDependencies {
  metadataService: TxMetadataService;
  db: Pool;
  logger: Logger;
}

/**
 * NftMetadataService implementation using cardano-db-sync database as a source
 */
export class DbSyncNftMetadataService implements NftMetadataService {
  #builder: AssetBuilder;
  #logger: Logger;
  #metadataService: TxMetadataService;

  constructor({ db, logger, metadataService }: DbSyncNftMetadataServiceDependencies) {
    this.#builder = new AssetBuilder(db, logger);
    this.#logger = logger;
    this.#metadataService = metadataService;
  }

  async getNftMetadata(assetInfo: AssetPolicyIdAndName): Promise<Asset.NftMetadata | null> {
    // Perf: could query last mint tx metadata in 1 query instead of 2
    const lastMintedTx = await this.#builder.queryLastMintTx(assetInfo.policyId, assetInfo.name);

    if (!lastMintedTx) return null;

    const lastMintedTxId = Cardano.TransactionId(lastMintedTx.tx_hash.toString('hex'));

    this.#logger.debug('Querying tx metadata', lastMintedTxId);
    const metadatas = await this.#metadataService.queryTxMetadataByHashes([lastMintedTxId]);
    const metadata = metadatas.get(lastMintedTxId);
    return Asset.util.metadatumToCip25(assetInfo, metadata, this.#logger);
  }
}
