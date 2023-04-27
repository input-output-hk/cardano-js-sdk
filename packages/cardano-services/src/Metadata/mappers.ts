import { CML, Cardano, cmlToCore } from '@cardano-sdk/core';
import { TxMetadataModel } from './types';
import { usingAutoFree } from '@cardano-sdk/util';

export const mapTxMetadata = (metadataModel: Pick<TxMetadataModel, 'bytes' | 'key'>[]): Cardano.TxMetadata =>
  metadataModel.reduce((map, metadatum) => {
    const { bytes, key } = metadatum;

    if (bytes && key) {
      const biKey = BigInt(key);
      const metadata = usingAutoFree((scope) =>
        cmlToCore.txMetadata(scope.manage(CML.GeneralTransactionMetadata.from_bytes(bytes)))
      );

      if (metadata) {
        const datum = metadata.get(biKey);

        if (datum) map.set(biKey, datum);
      }
    }

    return map;
  }, new Map<bigint, Cardano.Metadatum>());
