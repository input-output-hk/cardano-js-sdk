import { Cardano, ProviderUtil } from '@cardano-sdk/core';
import { TxMetadataModel } from './types';

export const mapTxMetadata = (metadataModel: Pick<TxMetadataModel, 'json_value' | 'key'>[]): Cardano.TxMetadata =>
  metadataModel.reduce((map, metadatum) => {
    const { key, json_value } = metadatum;
    if (!json_value || !key) return map;
    map.set(BigInt(key), ProviderUtil.jsonToMetadatum(json_value));
    return map;
  }, new Map<bigint, Cardano.Metadatum>());
