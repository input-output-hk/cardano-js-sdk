import type { Cardano } from '@cardano-sdk/core';

export interface TxMetadataService {
  queryTxMetadataByHashes(hashes: Cardano.TransactionId[]): Promise<Map<Cardano.TransactionId, Cardano.TxMetadata>>;
  queryTxMetadataByRecordIds(ids: string[]): Promise<Map<string, Cardano.TxMetadata>>;
}

export interface TxMetadataModel {
  bytes: Uint8Array;
  key: string;
  tx_id: Buffer;
}
