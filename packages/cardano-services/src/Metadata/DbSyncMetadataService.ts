import * as Queries from './queries.js';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapTxMetadataByHashes } from './util.js';
import type { Cardano } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';
import type { TxMetadataModel, TxMetadataService } from './types.js';

export type TxMetadataByHashes = Map<Cardano.TransactionId, Cardano.TxMetadata>;

export const createDbSyncMetadataService = (db: Pool, logger: Logger): TxMetadataService => ({
  async queryTxMetadataByHashes(hashes: Cardano.TransactionId[]): Promise<TxMetadataByHashes> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash));
    logger.debug('About to find metadata for txs:', hashes);

    const result = await db.query<TxMetadataModel>({
      name: 'tx_metadata',
      text: Queries.findTxMetadataByTxHashes,
      values: [byteHashes]
    });

    if (result.rows.length === 0) return new Map();
    return mapTxMetadataByHashes(result.rows);
  },

  async queryTxMetadataByRecordIds(ids: string[]): Promise<TxMetadataByHashes> {
    logger.debug('About to find metadata for transactions with ids:', ids);

    const result: QueryResult<TxMetadataModel> = await db.query({
      name: 'tx_metadata_by_tx_ids',
      text: Queries.findTxMetadataByTxIds,
      values: [ids]
    });

    if (result.rows.length === 0) return new Map();
    return mapTxMetadataByHashes(result.rows);
  }
});
