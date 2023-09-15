import { Cardano, Serialization } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { TxMetadataModel } from './types';

export const mapTxMetadata = (metadataModel: Pick<TxMetadataModel, 'bytes' | 'key'>[]): Cardano.TxMetadata =>
  metadataModel.reduce((map, metadatum) => {
    const { bytes, key } = metadatum;

    if (bytes && key) {
      const biKey = BigInt(key);
      const metadata = Serialization.GeneralTransactionMetadata.fromCbor(HexBlob.fromBytes(bytes)).toCore();

      if (metadata) {
        const datum = metadata.get(biKey);

        if (datum) map.set(biKey, datum);
      }
    }

    return map;
  }, new Map<bigint, Cardano.Metadatum>());
