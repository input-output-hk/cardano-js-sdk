import { Cardano } from '@cardano-sdk/core';
import { TxMetadataByHashes } from './DbSyncMetadataService';
import { TxMetadataModel } from './types';
import { mapTxMetadata } from './mappers';

export const mapTxMetadataByHashes = (listOfMetadata: TxMetadataModel[]): TxMetadataByHashes => {
  const metadataMap: Map<Cardano.TransactionId, TxMetadataModel[]> = new Map();

  for (const metadata of listOfMetadata) {
    const txId = metadata.tx_id.toString('hex') as Cardano.TransactionId;
    const currentMetadata: TxMetadataModel[] = metadataMap.get(txId) ?? [];
    metadataMap.set(txId, [...currentMetadata, metadata]);
  }

  return new Map([...metadataMap].map(([id, metadata]) => [id, mapTxMetadata(metadata)]));
};
