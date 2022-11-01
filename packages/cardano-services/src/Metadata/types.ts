import { Cardano } from '@cardano-sdk/core';

export interface TxMetadataService {
  queryTxMetadataByHashes(hashes: Cardano.TransactionId[]): Promise<Map<Cardano.TransactionId, Cardano.TxMetadata>>;
}

export interface TxMetadataModel {
  key: string;
  json_value: { [k: string]: unknown };
  tx_id: Buffer;
}
