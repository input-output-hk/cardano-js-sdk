import * as Queries from './queries';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { TxMetadataModel, TxMetadataService } from './types';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapTxMetadata } from './mappers';

export type TxMetadataByHashes = Map<Cardano.TransactionId, Cardano.TxMetadata>;

export const createDbSyncMetadataService = (db: Pool, logger: Logger): TxMetadataService => ({
  async queryTxMetadataByHashes(hashes: Cardano.TransactionId[]): Promise<TxMetadataByHashes> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    logger.debug('About to find metadata for txs:', hashes);

    const result: QueryResult<TxMetadataModel> = await db.query(Queries.findTxMetadata, [byteHashes]);

    if (result.rows.length === 0) return new Map();
    const metadataMap: Map<Cardano.TransactionId, TxMetadataModel[]> = new Map();

    for (const metadata of result.rows) {
      const txId = metadata.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentMetadata: TxMetadataModel[] = metadataMap.get(txId) ?? [];
      metadataMap.set(txId, [...currentMetadata, metadata]);
    }

    return new Map([...metadataMap].map(([id, metadata]) => [id, mapTxMetadata(metadata)]));
  }
});
