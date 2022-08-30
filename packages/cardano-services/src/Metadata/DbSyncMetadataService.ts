import * as Queries from './queries';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { MetadataService, TxMetadataModel } from './types';
import { Pool, QueryResult } from 'pg';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapTxMetadata } from './mappers';

export const createDbSyncMetadataService = (db: Pool, logger: Logger): MetadataService => ({
  async queryTxMetadataByHashes(
    hashes: Cardano.TransactionId[]
  ): Promise<Map<Cardano.TransactionId, Cardano.TxMetadata>> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    logger.debug('About to find metadata for txs:', hashes);
    const result: QueryResult<TxMetadataModel> = await db.query(Queries.findTxMetadata, [byteHashes]);
    if (result.rows.length === 0) return new Map();
    const metadataMap: Map<Cardano.TransactionId, TxMetadataModel[]> = new Map();
    for (const metadata of result.rows) {
      const txId = Cardano.TransactionId(metadata.tx_id.toString('hex'));
      const currentMetadata: TxMetadataModel[] = metadataMap.get(txId) ?? [];
      metadataMap.set(txId, [...currentMetadata, metadata]);
    }
    return new Map([...metadataMap].map(([id, metadata]) => [id, mapTxMetadata(metadata)]));
  }
});
