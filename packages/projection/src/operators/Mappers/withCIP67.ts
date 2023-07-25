import { Asset, Cardano } from '@cardano-sdk/core';
import { ProducedUtxo, WithUtxo } from './withUtxo';
import { isNotNil } from '@cardano-sdk/util';
import { unifiedProjectorOperator } from '../utils';
import groupBy from 'lodash/groupBy';

export interface CIP67Asset {
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
  assetName: Cardano.AssetName;
  decoded: Asset.DecodedAssetName;
  utxo: ProducedUtxo;
}

export interface WithCIP67 {
  cip67: {
    byLabel: Partial<Record<Asset.AssetNameLabel, CIP67Asset[]>>;
  };
}

export const withCIP67 = unifiedProjectorOperator<WithUtxo, WithCIP67>((evt) => ({
  ...evt,
  cip67: {
    byLabel: groupBy(
      evt.utxo.produced
        .flatMap((utxo) =>
          [...(utxo[1].value.assets?.keys() || [])].map((assetId): CIP67Asset | null => {
            const assetName = Cardano.AssetId.getAssetName(assetId);
            const decoded = Asset.AssetNameLabel.decode(assetName);
            if (!decoded) return null;
            return {
              assetId,
              assetName,
              decoded,
              policyId: Cardano.AssetId.getPolicyId(assetId),
              utxo
            };
          })
        )
        .filter(isNotNil),
      (e) => e.decoded.label
    )
  }
}));
